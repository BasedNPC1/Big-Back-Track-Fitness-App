import SwiftUI
import UIKit
import Combine

struct DashboardView: View {
    @ObservedObject var foodLogViewModel: FoodLogViewModel
    @ObservedObject var userGoalViewModel: UserGoalViewModel
    @StateObject private var chatViewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingLoginView = false
    
    // Colors for the vibrant theme (matching other views)
    let darkBackground = Color.black
    let accentColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    
    init(foodLogViewModel: FoodLogViewModel, userGoalViewModel: UserGoalViewModel) {
        self.foodLogViewModel = foodLogViewModel
        self.userGoalViewModel = userGoalViewModel
        self._chatViewModel = StateObject(wrappedValue: ChatViewModel(foodLogViewModel: foodLogViewModel, userGoalViewModel: userGoalViewModel))
    }
    
    var body: some View {
        ZStack {
            // Custom gradient background for dashboard
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.2),  // Deep blue
                    Color(red: 0.1, green: 0.1, blue: 0.3),    // Medium blue
                    Color(red: 0.0, green: 0.0, blue: 0.1)     // Almost black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // Semi-transparent overlay for better text readability
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                HStack {
                    Spacer()
                    
                    Text("DASHBOARD")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Logout button
                    Button(action: {
                        showingLoginView = true
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 22))
                            .foregroundColor(accentColor)
                    }
                }
                .padding(.horizontal)
                
                Text("Your Nutrition Summary")
                    .font(.headline)
                    .foregroundColor(accentColor)
                    .padding(.bottom, 10)
                
                // Today's stats
                VStack(spacing: 15) {
                    // Today's date
                    Text(formattedDate())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Calories consumed today
                    HStack {
                        Text("Calories Today:")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(getTotalCaloriesConsumed()) kcal")
                            .foregroundColor(accentColor)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    
                    // Protein consumed today
                    HStack {
                        Text("Protein Today:")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(getTotalProteinConsumed())g")
                            .foregroundColor(accentColor)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(red: 0.1, green: 0.1, blue: 0.15))
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
                
                // Chat View
                ChatView(chatViewModel: chatViewModel)
                    .padding(.horizontal)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showingLoginView) {
            LoginView()
        }
    }
    
    // Format today's date
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
    
    // Calculate total calories consumed today from food entries
    private func getTotalCaloriesConsumed() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Filter entries from today
        let todaysEntries = foodLogViewModel.foodEntries.filter { entry in
            return calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
        
        // Sum up calories
        var totalCalories = 0
        for entry in todaysEntries {
            totalCalories += Int(entry.macros.calories)
        }
        return totalCalories
    }
    
    // Calculate total protein consumed today from food entries
    private func getTotalProteinConsumed() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Filter entries from today
        let todaysEntries = foodLogViewModel.foodEntries.filter { entry in
            return calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
        
        // Sum up protein
        var totalProtein = 0
        for entry in todaysEntries {
            totalProtein += Int(entry.macros.protein)
        }
        return totalProtein
    }
}

#Preview {
    DashboardView(foodLogViewModel: FoodLogViewModel(), userGoalViewModel: UserGoalViewModel())
}
