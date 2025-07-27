import Foundation
import SwiftUI

// Model to manage the multi-step sign-up process
class SignUpModel: ObservableObject {
    // Step 1: Account Information
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var termsAccepted = false
    @Published var selectedAvatarColor = 0
    
    // Step 2: Personal Information
    @Published var age = ""
    @Published var gender = Gender.other
    @Published var height = "" // Will be converted to Double
    @Published var weight = "" // Will be converted to Double
    @Published var useMetricSystem = true // true for metric (cm/kg), false for imperial (in/lb)
    
    // Navigation state
    @Published var currentStep = 1
    @Published var showingMainView = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var animateButton = false
    
    // UI state
    @Published var showPassword = false
    @Published var showConfirmPassword = false
    
    // Avatar color options (matching SignupView)
    let avatarColors = [Color.blue, Color.green, Color.orange, Color.purple, Color.pink]
    
    enum Gender: String, CaseIterable, Identifiable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
        
        var id: String { self.rawValue }
    }
    
    // Validate step 1 (account information)
    func validateStep1() -> Bool {
        // Reset error state
        showError = false
        
        // Validate username
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Username is required"
            showError = true
            return false
        }
        
        // Validate email
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Email is required"
            showError = true
            return false
        }
        
        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email"
            showError = true
            return false
        }
        
        // Validate password
        if password.isEmpty {
            errorMessage = "Password is required"
            showError = true
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords don't match"
            showError = true
            return false
        }
        
        if !termsAccepted {
            errorMessage = "Please accept the terms"
            showError = true
            return false
        }
        
        return true
    }
    
    // Validate step 2 (personal information)
    func validateStep2() -> Bool {
        // Reset error state
        showError = false
        
        // Validate age
        if age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Age is required"
            showError = true
            return false
        }
        
        guard let ageValue = Int(age), ageValue >= 13, ageValue <= 100 else {
            errorMessage = "Please enter a valid age (13-100)"
            showError = true
            return false
        }
        
        // Validate height
        if height.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Height is required"
            showError = true
            return false
        }
        
        guard let heightValue = Double(height), heightValue > 0 else {
            errorMessage = "Please enter a valid height"
            showError = true
            return false
        }
        
        // Validate weight
        if weight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Weight is required"
            showError = true
            return false
        }
        
        guard let weightValue = Double(weight), weightValue > 0 else {
            errorMessage = "Please enter a valid weight"
            showError = true
            return false
        }
        
        return true
    }
    
    // Helper to validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Convert height to cm for storage
    func getHeightInCm() -> Double {
        guard let heightValue = Double(height) else { return 0 }
        return useMetricSystem ? heightValue : heightValue * 2.54 // Convert inches to cm
    }
    
    // Convert weight to kg for storage
    func getWeightInKg() -> Double {
        guard let weightValue = Double(weight) else { return 0 }
        return useMetricSystem ? weightValue : weightValue * 0.453592 // Convert lbs to kg
    }
    
    // Complete signup and prepare user data
    func completeSignUp() -> UserGoal {
        // Create user goal from sign-up data
        let userGoal = UserGoal(
            height: getHeightInCm(),
            weight: getWeightInKg(),
            age: Int(age) ?? 25,
            gender: mapGender(gender),
            targetWeight: getWeightInKg(), // Initially set target weight same as current
            timeframe: 12, // Default 12 weeks
            bodyFat: nil, // Optional, not collected during sign-up
            dailyCalories: 2000, // Default values, will be calculated later
            dailyProtein: 150,
            dailyCarbs: 200,
            dailyFat: 60
        )
        
        return userGoal
    }
    
    // Map SignUpModel.Gender to UserGoal.Gender
    private func mapGender(_ gender: Gender) -> UserGoal.Gender {
        switch gender {
        case .male:
            return .male
        case .female:
            return .female
        case .other:
            return .other
        }
    }
}
