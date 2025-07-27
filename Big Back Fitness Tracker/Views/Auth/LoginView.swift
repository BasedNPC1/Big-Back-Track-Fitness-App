import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showingMainView = false
    @State private var showingSignUp = false
    @State private var showError = false
    @State private var isGuest = false
    @State private var showPassword = false
    @State private var animateTitle = false
    @State private var animateButton = false
    
    // Colors for the vibrant theme
    let darkBackground = Color.black
    let gradientStart = Color(red: 0.0, green: 0.8, blue: 0.8) // Teal
    let gradientEnd = Color(red: 0.5, green: 0.0, blue: 0.8) // Purple
    let accentColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    let secondaryColor = Color(red: 0.15, green: 0.15, blue: 0.2) // Dark blue-gray
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(gradient: Gradient(colors: [darkBackground.opacity(0.9), darkBackground]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Subtle animated background elements
            ZStack {
                ForEach(0..<5) { i in
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: CGFloat.random(in: 40...80)))
                        .foregroundColor(Color.white.opacity(0.03))
                        .position(x: CGFloat.random(in: 50...350), 
                                  y: CGFloat.random(in: 100...700))
                        .rotationEffect(.degrees(Double.random(in: 0...360)))
                }
            }
            
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 15) {
                    // 3D-like animated dumbbell
                    ZStack {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 85))
                            .foregroundColor(accentColor.opacity(0.7))
                            .offset(x: 3, y: 3)
                        
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 80))
                            .foregroundColor(accentColor)
                            .scaleEffect(animateTitle ? 1.05 : 1.0)
                            .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateTitle)
                    }
                    .onAppear { animateTitle = true }
                    
                    // Dynamic title
                    Text("BIG BACK TRACKER")
                        .font(.custom("Montserrat-Bold", size: 28, relativeTo: .title))
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [gradientStart, gradientEnd], 
                                startPoint: .leading, 
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(animateTitle ? 1.02 : 1.0)
                        .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateTitle)
                    
                    // Positive tagline
                    Text("BUILD YOUR BEST BACK!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(accentColor)
                        .padding(.bottom, 20)
                }
                
                // Login Form with animated focus
                VStack(spacing: 20) {
                    // Username field
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(accentColor)
                            .padding(.leading, 10)
                        
                        TextField("", text: $username)
                            .placeholder(when: username.isEmpty) {
                                Text("USERNAME").foregroundColor(.gray.opacity(0.7))
                            }
                            .padding(.vertical, 12)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .background(secondaryColor)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                    )
                    
                    // Password field with show/hide
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(accentColor)
                            .padding(.leading, 10)
                        
                        if showPassword {
                            TextField("", text: $password)
                                .placeholder(when: password.isEmpty) {
                                    Text("PASSWORD").foregroundColor(.gray.opacity(0.7))
                                }
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                        } else {
                            SecureField("", text: $password)
                                .placeholder(when: password.isEmpty) {
                                    Text("PASSWORD").foregroundColor(.gray.opacity(0.7))
                                }
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                    .background(secondaryColor)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                    )
                    
                    if showError {
                        Text("Oops! Let's try that again.")
                            .foregroundColor(accentColor)
                            .font(.system(size: 14, weight: .bold))
                    }
                    
                    // Biometric login option
                    HStack {
                        Text("Use Face ID")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            // For MVP, just navigate to main view
                            showingMainView = true
                        }) {
                            Image(systemName: "faceid")
                                .font(.title2)
                                .foregroundColor(accentColor)
                        }
                    }
                    .padding(.top, 5)
                    
                    // Login button with animation
                    Button(action: {
                        // For MVP, just navigate to main view without authentication
                        withAnimation {
                            animateButton = true
                            
                            // Delay to allow animation to complete
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showingMainView = true
                            }
                        }
                    }) {
                        Text("LOGIN")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [accentColor, accentColor.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(15)
                            .shadow(color: accentColor.opacity(0.5), radius: 5, x: 0, y: 3)
                            .scaleEffect(animateButton ? 0.95 : 1.0)
                    }
                    .padding(.top, 10)
                    
                    // Guest toggle
                    Toggle(isOn: $isGuest) {
                        Text("Continue as Guest")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: accentColor))
                    .padding(.top, 10)
                    .onChange(of: isGuest) { newValue in
                        if newValue {
                            // For MVP, navigate to main view if guest mode is enabled
                            showingMainView = true
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                // Social login options
                HStack(spacing: 25) {
                    Button(action: {
                        // For MVP, just navigate to main view
                        showingMainView = true
                    }) {
                        Image(systemName: "apple.logo")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        // For MVP, just navigate to main view
                        showingMainView = true
                    }) {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        // For MVP, just navigate to main view
                        showingMainView = true
                    }) {
                        Image(systemName: "t.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 20)
                
                // Sign Up Option
                HStack {
                    Text("New to the grind?")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        showingSignUp = true
                    }) {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [gradientStart, gradientEnd], 
                                    startPoint: .leading, 
                                    endPoint: .trailing
                                )
                            )
                    }
                }
                .padding(.top, 15)
                
                // Share progress teaser
                Text("Log in to unlock shareable gains!")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.top, 10)
            }
            .padding(.vertical, 40)
        }
        .fullScreenCover(isPresented: $showingMainView) {
            // This will be replaced with your main app view
            MainTabView()
        }
        .sheet(isPresented: $showingSignUp) {
            // This will be replaced with your sign up view
            SignupView()
                .presentationDetents([.large])
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Start animations when view appears
            animateTitle = true
        }
        .onChange(of: animateButton) { newValue in
            // Reset button animation after delay
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animateButton = false
                }
            }
        }
    }
}

// Helper extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    LoginView()
}
