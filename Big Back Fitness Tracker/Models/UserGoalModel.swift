import Foundation
import SwiftUI

// Model to store user's personal information and goals
struct UserGoal: Codable {
    var username: String = "" // User's name for personalization
    var height: Double // in cm
    var weight: Double // in kg
    var age: Int
    var gender: Gender
    var targetWeight: Double // in kg
    var timeframe: Int // in weeks
    var bodyFat: Double? // optional, in percentage
    
    // Computed goal outputs
    var dailyCalories: Int = 0
    var dailyProtein: Double = 0 // in grams
    var dailyCarbs: Double = 0 // in grams
    var dailyFat: Double = 0 // in grams
    
    enum Gender: String, CaseIterable, Identifiable, Codable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
        
        var id: String { self.rawValue }
    }
}

class UserGoalViewModel: ObservableObject {
    @Published var userGoal: UserGoal?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let openAIService = OpenAIService()
    private let userDefaultsKey = "userGoal"
    
    init() {
        // Load existing goal from UserDefaults if available
        loadUserGoal()
    }
    
    func loadUserGoal() {
        // Attempt to load user goal from UserDefaults
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let decoder = JSONDecoder()
                let savedGoal = try decoder.decode(UserGoal.self, from: savedData)
                self.userGoal = savedGoal
            } catch {
                print("Error loading user goal: \(error)")
                // If loading fails, userGoal remains nil
            }
        }
    }
    
    func saveUserGoal() {
        // Save current user goal to UserDefaults
        if let goal = userGoal {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(goal)
                UserDefaults.standard.set(data, forKey: userDefaultsKey)
            } catch {
                print("Error saving user goal: \(error)")
            }
        }
    }
    
    func calculateGoals(height: Double, weight: Double, age: Int, gender: UserGoal.Gender, 
                        targetWeight: Double, timeframe: Int, bodyFat: Double?) {
        isLoading = true
        errorMessage = nil
        
        // Create a prompt for OpenAI to calculate nutrition goals
        let prompt = """
        Calculate daily nutrition goals for a person with the following characteristics:
        - Height: \(height) cm
        - Current Weight: \(weight) kg
        - Age: \(age) years
        - Gender: \(gender.rawValue)
        - Target Weight: \(targetWeight) kg
        - Timeframe: \(timeframe) weeks
        \(bodyFat != nil ? "- Body Fat Percentage: \(bodyFat!)%" : "")
        
        Please provide the following in JSON format:
        - Daily calorie intake
        - Daily protein in grams
        - Daily carbohydrates in grams
        - Daily fat in grams
        
        Response format:
        {
          "dailyCalories": 2000,
          "dailyProtein": 150,
          "dailyCarbs": 200,
          "dailyFat": 60
        }
        """
        
        // Call OpenAI API to get nutrition recommendations
        openAIService.getNutritionData(prompt: prompt) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let nutritionData):
                    // Create user goal with the calculated values
                    self?.userGoal = UserGoal(
                        height: height,
                        weight: weight,
                        age: age,
                        gender: gender,
                        targetWeight: targetWeight,
                        timeframe: timeframe,
                        bodyFat: bodyFat,
                        dailyCalories: Int(nutritionData.calories),
                        dailyProtein: nutritionData.macros.protein,
                        dailyCarbs: nutritionData.macros.carbs,
                        dailyFat: nutritionData.macros.fat
                    )
                    
                    // Save the goal to UserDefaults for persistence
                    self?.saveUserGoal()
                    
                case .failure(let error):
                    self?.errorMessage = "Failed to calculate goals: \(error.localizedDescription)"
                    
                    // Use default values as fallback
                    let defaultCalories = self?.calculateBasalMetabolicRate(
                        weight: weight, 
                        height: height, 
                        age: age, 
                        gender: gender,
                        targetWeight: targetWeight,
                        timeframe: timeframe
                    ) ?? 2000
                    
                    self?.userGoal = UserGoal(
                        height: height,
                        weight: weight,
                        age: age,
                        gender: gender,
                        targetWeight: targetWeight,
                        timeframe: timeframe,
                        bodyFat: bodyFat,
                        dailyCalories: defaultCalories,
                        dailyProtein: weight * 1.8, // 1.8g per kg of body weight
                        dailyCarbs: Double(defaultCalories) * 0.4 / 4.0, // 40% of calories from carbs
                        dailyFat: Double(defaultCalories) * 0.3 / 9.0 // 30% of calories from fat
                    )
                }
            }
        }
    }
    
    // Fallback calculation using Mifflin-St Jeor equation for BMR
    private func calculateBasalMetabolicRate(weight: Double, height: Double, age: Int, gender: UserGoal.Gender, targetWeight: Double, timeframe: Int) -> Int {
        var bmr: Double
        
        switch gender {
        case .male:
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) + 5
        case .female:
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) - 161
        case .other:
            // Average of male and female formulas
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) - 78
        }
        
        // Adjust based on weight goal
        let weeklyCalorieDifference = (weight - targetWeight) * 7700 / Double(timeframe) // 7700 calories ≈ 1kg
        let dailyCalorieDifference = weeklyCalorieDifference / 7
        
        // Add activity factor (moderate activity = 1.55)
        let tdee = bmr * 1.55
        
        // Adjust for weight goal
        let adjustedCalories = tdee - dailyCalorieDifference
        
        // Ensure minimum safe calorie intake
        let minCalories = gender == .male ? 1500 : 1200
        return max(Int(adjustedCalories), minCalories)
    }
}
