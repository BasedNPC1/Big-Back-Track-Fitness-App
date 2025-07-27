import SwiftUI

struct ProgressView: View {
    @ObservedObject var foodLogViewModel: FoodLogViewModel
    @ObservedObject var userGoalViewModel = UserGoalViewModel()
    
    // Colors for the vibrant theme (matching other views)
    let darkBackground = Color.black
    let gradientStart = Color(red: 0.0, green: 0.8, blue: 0.8) // Teal
    let gradientEnd = Color(red: 0.5, green: 0.0, blue: 0.8) // Purple
    let accentColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    let secondaryColor = Color(red: 0.15, green: 0.15, blue: 0.2) // Dark blue-gray
    let redColor = Color.red
    
    // Progress colors
    let lowProgressColor = Color.gray.opacity(0.7)
    let midProgressColor = Color.yellow
    let highProgressColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    
    var body: some View {
        ZStack {
            // Background
            darkBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("PROGRESS")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(.white)
                    
                    Text("View your gains over time")
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                    // Calories Progress Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CALORIES")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Get total calories consumed today
                        let consumedCalories = getTotalCaloriesConsumed()
                        let targetCalories = userGoalViewModel.userGoal?.dailyCalories ?? 2000
                        let caloriesProgress = min(1.0, Double(consumedCalories) / Double(targetCalories))
                        
                        // Progress bar
                        ProgressBar(
                            value: caloriesProgress,
                            lowColor: lowProgressColor,
                            highColor: highProgressColor
                        )
                        
                        // Stats
                        HStack {
                            Text("\(consumedCalories) / \(targetCalories) kcal")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(Int(caloriesProgress * 100))%")
                                .font(.subheadline)
                                .foregroundColor(progressColor(for: caloriesProgress))
                        }
                        
                        // Roasting response for calories
                        Text(caloriesRoastingResponse(for: caloriesProgress))
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(secondaryColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Protein Progress Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PROTEIN")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Get total protein consumed today
                        let consumedProtein = getTotalProteinConsumed()
                        let targetProtein = userGoalViewModel.userGoal?.dailyProtein ?? 150
                        let proteinProgress = min(1.0, consumedProtein / targetProtein)
                        
                        // Progress bar
                        ProgressBar(
                            value: proteinProgress,
                            lowColor: lowProgressColor,
                            highColor: highProgressColor
                        )
                        
                        // Stats
                        HStack {
                            Text("\(Int(consumedProtein)) / \(Int(targetProtein)) g")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(Int(proteinProgress * 100))%")
                                .font(.subheadline)
                                .foregroundColor(progressColor(for: proteinProgress))
                        }
                        
                        // Roasting response for protein
                        Text(proteinRoastingResponse(for: proteinProgress))
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(secondaryColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Motivational message
                    if let userGoal = userGoalViewModel.userGoal {
                        VStack(spacing: 10) {
                            Text("GOAL PROGRESS")
                                .font(.headline)
                                .foregroundColor(accentColor)
                            
                            let caloriesProgress = min(1.0, Double(getTotalCaloriesConsumed()) / Double(userGoal.dailyCalories))
                            let proteinProgress = min(1.0, getTotalProteinConsumed() / userGoal.dailyProtein)
                            let avgProgress = (caloriesProgress + proteinProgress) / 2
                            
                            Text(motivationalMessage(for: avgProgress))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(secondaryColor)
                        )
                        .padding(.horizontal)
                    } else {
                        // No goal set yet
                        VStack(spacing: 15) {
                            Image(systemName: "target")
                                .font(.system(size: 40))
                                .foregroundColor(accentColor)
                            
                            Text("No goals set yet")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Set your nutrition goals in the Food Log tab to track your progress")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(secondaryColor)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            // Refresh data when view appears
            loadUserGoal()
            foodLogViewModel.fetchFoodEntries()
        }
    }
    
    // Calculate total calories consumed today from food entries
    private func getTotalCaloriesConsumed() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return foodLogViewModel.foodEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + Int($1.macros.calories) }
    }
    
    // Calculate total protein consumed today from food entries
    private func getTotalProteinConsumed() -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return foodLogViewModel.foodEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + $1.macros.protein }
    }
    
    // Load user goal if not already loaded
    private func loadUserGoal() {
        // Force refresh the user goal from the view model
        // This ensures we always have the latest goal data
        userGoalViewModel.loadUserGoal()
        
        // If still nil after attempting to load (first launch), set a default goal
        if userGoalViewModel.userGoal == nil {
            // Set a default goal if none exists
            userGoalViewModel.userGoal = UserGoal(
                height: 175,
                weight: 70,
                age: 30,
                gender: .male,
                targetWeight: 75,
                timeframe: 12,
                bodyFat: 15,
                dailyCalories: 2500,
                dailyProtein: 150,
                dailyCarbs: 250,
                dailyFat: 80
            )
        }
    }
    
    // Return appropriate color based on progress
    private func progressColor(for value: Double) -> Color {
        switch value {
        case 0..<0.3:
            return lowProgressColor
        case 0.3..<0.7:
            return midProgressColor
        default:
            return highProgressColor
        }
    }
    
    // Return motivational message based on progress
    private func motivationalMessage(for progress: Double) -> String {
        switch progress {
        case 0..<0.2:
            return "You're just getting started. Time to crush those macros!"
        case 0.2..<0.5:
            return "Making progress, but you're still soft. Keep pushing!"
        case 0.5..<0.8:
            return "Halfway there! Don't stop now, the gains are coming!"
        case 0.8..<1.0:
            return "Almost there! Finish strong and hit those targets!"
        default:
            return "You've hit your targets! Beast mode activated! 💪"
        }
    }
    
    // Roasting responses for calories progress
    private func caloriesRoastingResponse(for progress: Double) -> String {
        switch progress {
        case 0..<0.1:
            return "Are you even trying? My grandma eats more than you!"
        case 0.1..<0.3:
            return "What is this, a diet for ANTS? EAT SOMETHING!"
        case 0.3..<0.5:
            return "Half your calories? What are you, a rabbit? BULK UP!"
        case 0.5..<0.7:
            return "Getting there, but still looking WEAK. More food!"
        case 0.7..<0.9:
            return "Almost there. Stop being a calorie coward!"
        case 0.9..<1.0:
            return "So close! One more bite, you can do it, baby bird!"
        case 1.0..<1.1:
            return "Wow, you actually hit your calories. Want a participation trophy?"
        case 1.1..<1.3:
            return "Slightly over? That's cute. Real gainers go 150%!"
        default:
            return "OK big shot, you hit your calories. Now do it again tomorrow!"
        }
    }
    
    // Roasting responses for protein progress
    private func proteinRoastingResponse(for progress: Double) -> String {
        switch progress {
        case 0..<0.1:
            return "Zero protein? Enjoy your muscle LOSS, noodle arms!"
        case 0.1..<0.3:
            return "That's barely enough protein for a CHILD. Do better!"
        case 0.3..<0.5:
            return "Half your protein? Your muscles are CRYING right now!"
        case 0.5..<0.7:
            return "Getting there, but your biceps are still DISAPPOINTED!"
        case 0.7..<0.9:
            return "Almost enough protein. Your gains are still at risk, weakling!"
        case 0.9..<1.0:
            return "So close! One more shake, unless you HATE muscles?"
        case 1.0..<1.1:
            return "Hit your protein? Bare minimum achievement unlocked!"
        case 1.1..<1.3:
            return "Slightly over protein? That's what I call a BEGINNER effort!"
        default:
            return "Protein goal crushed! Still looking small though!"
        }
    }
}

// Custom Progress Bar Component
struct ProgressBar: View {
    var value: Double // 0.0 to 1.0
    var lowColor: Color
    var highColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.3))
                    .cornerRadius(10)
                
                // Progress
                Rectangle()
                    .frame(width: geometry.size.width * CGFloat(value))
                    .foregroundColor(getColorForProgress(lowColor: lowColor, highColor: highColor, progress: value))
                    .cornerRadius(10)
            }
        }
        .frame(height: 20)
    }
}

// Helper to get color from position in gradient
func getColorForProgress(lowColor: Color, highColor: Color, progress: Double) -> Color {
    let adjustedProgress = min(max(progress, 0), 1)
    
    // Blend between the colors based on progress
    if adjustedProgress < 0.5 {
        // In the first half, transition from lowColor to a mix
        let blendFactor = adjustedProgress * 2 // Scale to 0-1 range
        return lowColor.opacity(0.7 + blendFactor * 0.3) // Increase opacity with progress
    } else {
        // In the second half, transition to highColor
        let blendFactor = (adjustedProgress - 0.5) * 2 // Scale to 0-1 range
        return Color(
            red: lowColor.components.red * (1 - blendFactor) + highColor.components.red * blendFactor,
            green: lowColor.components.green * (1 - blendFactor) + highColor.components.green * blendFactor,
            blue: lowColor.components.blue * (1 - blendFactor) + highColor.components.blue * blendFactor
        )
    }
}

// Extension to get RGB components from a Color
extension Color {
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // Default to black if conversion fails
            return (0, 0, 0, 0)
        }
        
        return (Double(r), Double(g), Double(b), Double(o))
    }
}

#Preview {
    ProgressView(foodLogViewModel: FoodLogViewModel())
}
