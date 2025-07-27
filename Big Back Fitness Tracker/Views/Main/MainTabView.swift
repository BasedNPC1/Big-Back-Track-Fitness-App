import SwiftUI

struct MainTabView: View {
    // Colors for the vibrant theme (matching LoginView)
    let darkBackground = Color.black
    let gradientStart = Color(red: 0.0, green: 0.8, blue: 0.8) // Teal
    let gradientEnd = Color(red: 0.5, green: 0.0, blue: 0.8) // Purple
    let accentColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    let secondaryColor = Color(red: 0.15, green: 0.15, blue: 0.2) // Dark blue-gray
    
    var body: some View {
        TabView {
            // Dashboard Tab
            VStack {
                Text("DASHBOARD")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(.white)
                
                Text("Your nutrition stats will appear here")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(darkBackground)
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            
            // Food Logging Tab
            FoodLogView()
                .tabItem {
                    Label("Log Food", systemImage: "fork.knife")
                }
            
            // Progress Tab
            VStack {
                Text("PROGRESS")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(.white)
                
                Text("View your gains over time")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(darkBackground)
            .tabItem {
                Label("Progress", systemImage: "chart.xyaxis.line")
            }
            
            // Profile Tab
            VStack {
                Text("PROFILE")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(.white)
                
                Text("Your settings and goals")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(darkBackground)
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .accentColor(accentColor)
        .preferredColorScheme(.dark)
        .onAppear {
            // Set tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.black
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
}
