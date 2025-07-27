import Foundation
import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputMessage: String = ""
    @Published var isLoading: Bool = false
    
    private var openAIService: OpenAIService
    private var foodLogViewModel: FoodLogViewModel?
    private var userGoalViewModel: UserGoalViewModel?
    
    init(openAIService: OpenAIService = OpenAIService(), foodLogViewModel: FoodLogViewModel? = nil, userGoalViewModel: UserGoalViewModel? = nil) {
        self.openAIService = openAIService
        self.foodLogViewModel = foodLogViewModel
        self.userGoalViewModel = userGoalViewModel
        
        // Get user's name for personalized welcome
        let username = UserDefaults.standard.string(forKey: "username") ?? "lil bro"
        
        // Add personalized welcome message
        let welcomeMessage = ChatMessage(
            id: UUID().uuidString,
            content: "Sup \(username) 🤣🫵! I'm your Young Nigga nutrition assistant. Ask me anything about nutrition, your goals, or how to improve your life, I mean image !",
            isFromUser: false,
            timestamp: Date()
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage() {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: inputMessage,
            isFromUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        
        let userQuery = inputMessage
        inputMessage = ""
        isLoading = true
        
        // Create context from user's progress and food logs
        var contextInfo = ""
        
        // Add user identity context
        let username = UserDefaults.standard.string(forKey: "username") ?? "user"
        let userAge = UserDefaults.standard.integer(forKey: "userAge")
        let userGender = UserDefaults.standard.string(forKey: "userGender") ?? "Unknown"
        
        contextInfo += "User's name: \(username)\n"
        contextInfo += "User's age: \(userAge)\n"
        contextInfo += "User's gender: \(userGender)\n\n"
        
        // Add food log context if available
        if let foodLogVM = foodLogViewModel {
            let todayEntries = foodLogVM.foodEntries.filter { Calendar.current.isDateInToday($0.timestamp) }
            
            if !todayEntries.isEmpty {
                contextInfo += "\nToday's food log:\n"
                for entry in todayEntries {
                    contextInfo += "- \(entry.foodName): \(entry.weight) \(entry.unit) (\(Int(entry.macros.calories)) kcal, \(Int(entry.macros.protein))g protein)\n"
                }
                
                // Calculate totals using the same methods as in ProgressView
                let totalCalories = calculateTotalCalories(from: foodLogVM)
                let totalProtein = calculateTotalProtein(from: foodLogVM)
                contextInfo += "\nToday's totals: \(totalCalories) kcal, \(totalProtein)g protein\n"
            } else {
                contextInfo += "\nNo food logged today yet.\n"
            }
        }
        
        // Add user goals context if available
        if let userGoalVM = userGoalViewModel, let goal = userGoalVM.userGoal {
            contextInfo += "\nUser's goals:\n"
            
            // Add weight goal information (gain/lose/maintain)
            let weightDifference = goal.targetWeight - goal.weight
            let weightGoalType: String
            
            if abs(weightDifference) < 0.5 { // Less than 0.5kg difference is considered maintenance
                weightGoalType = "maintain weight"
            } else if weightDifference > 0 {
                weightGoalType = "gain weight (bulking)"
                contextInfo += "- Weight goal: Gain \(String(format: "%.1f", abs(weightDifference))) kg in \(goal.timeframe) weeks\n"
            } else {
                weightGoalType = "lose weight (cutting)"
                contextInfo += "- Weight goal: Lose \(String(format: "%.1f", abs(weightDifference))) kg in \(goal.timeframe) weeks\n"
            }
            
            contextInfo += "- Goal type: \(weightGoalType)\n"
            contextInfo += "- Current weight: \(String(format: "%.1f", goal.weight)) kg\n"
            contextInfo += "- Target weight: \(String(format: "%.1f", goal.targetWeight)) kg\n"
            contextInfo += "- Daily calorie target: \(Int(goal.dailyCalories)) kcal\n"
            contextInfo += "- Daily protein target: \(Int(goal.dailyProtein))g\n"
            contextInfo += "- Daily carbs target: \(Int(goal.dailyCarbs))g\n"
            contextInfo += "- Daily fat target: \(Int(goal.dailyFat))g\n"
            
            // Add progress percentages if food log is available
            if let foodLogVM = foodLogViewModel {
                let totalCalories = calculateTotalCalories(from: foodLogVM)
                let totalProtein = calculateTotalProtein(from: foodLogVM)
                let caloriePercentage = (Double(totalCalories) / Double(goal.dailyCalories)) * 100
                let proteinPercentage = (totalProtein / goal.dailyProtein) * 100
                
                contextInfo += "\nProgress today:\n"
                contextInfo += "- Calories: \(Int(caloriePercentage))% of daily goal\n"
                contextInfo += "- Protein: \(Int(proteinPercentage))% of daily goal\n"
            }
        } else {
            contextInfo += "\nNo nutrition goals set yet.\n"
        }
        
        // Combine user query with context
        let enhancedQuery = userQuery + "\n\nFor context (not visible to user): " + contextInfo
        
        openAIService.getChatResponse(for: enhancedQuery) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    let aiMessage = ChatMessage(
                        id: UUID().uuidString,
                        content: response,
                        isFromUser: false,
                        timestamp: Date()
                    )
                    self?.messages.append(aiMessage)
                    
                case .failure(let error):
                    print("Error getting chat response: \(error)")
                    let errorMessage = ChatMessage(
                        id: UUID().uuidString,
                        content: "Sorry, I couldn't process that request. Please try again later.",
                        isFromUser: false,
                        timestamp: Date()
                    )
                    self?.messages.append(errorMessage)
                }
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - Helper Methods
extension ChatViewModel {
    // Calculate total calories consumed today from food entries
    private func calculateTotalCalories(from viewModel: FoodLogViewModel) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return viewModel.foodEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + Int($1.macros.calories) }
    }
    
    // Calculate total protein consumed today from food entries
    private func calculateTotalProtein(from viewModel: FoodLogViewModel) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return viewModel.foodEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + $1.macros.protein }
    }
}
