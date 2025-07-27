import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var signUpModel = SignUpModel()
    @StateObject private var userGoalViewModel = UserGoalViewModel()
    
    // Colors for the vibrant theme (matching LoginView)
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
                ForEach(0..<3) { i in
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: CGFloat.random(in: 40...60)))
                        .foregroundColor(Color.white.opacity(0.03))
                        .position(x: CGFloat.random(in: 50...350), 
                                  y: CGFloat.random(in: 100...700))
                        .rotationEffect(.degrees(Double.random(in: 0...360)))
                }
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header with modern styling
                    VStack(spacing: 10) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [gradientStart, gradientEnd], 
                                    startPoint: .leading, 
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(signUpModel.currentStep == 1 ? "Step 1: Account Info" : "Step 2: Personal Info")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Progress indicator
                    HStack(spacing: 15) {
                        Circle()
                            .fill(signUpModel.currentStep >= 1 ? accentColor : Color.gray.opacity(0.5))
                            .frame(width: 12, height: 12)
                        
                        Rectangle()
                            .fill(signUpModel.currentStep > 1 ? accentColor : Color.gray.opacity(0.5))
                            .frame(width: 40, height: 2)
                        
                        Circle()
                            .fill(signUpModel.currentStep >= 2 ? accentColor : Color.gray.opacity(0.5))
                            .frame(width: 12, height: 12)
                    }
                    .padding(.bottom, 20)
                    
                    // Step content
                    if signUpModel.currentStep == 1 {
                        accountInfoStep
                    } else {
                        personalInfoStep
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
        .fullScreenCover(isPresented: $signUpModel.showingMainView) {
            MainTabView()
        }
        .preferredColorScheme(.dark)
        .onChange(of: signUpModel.animateButton) { oldValue, newValue in
            // Reset button animation after delay
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    signUpModel.animateButton = false
                }
            }
        }
        .alert(isPresented: $signUpModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(signUpModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Step 1: Account Info
    private var accountInfoStep: some View {
        VStack(spacing: 15) {
            // Avatar selection
            VStack(spacing: 10) {
                Circle()
                    .fill(signUpModel.avatarColors[signUpModel.selectedAvatarColor])
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                    .shadow(color: signUpModel.avatarColors[signUpModel.selectedAvatarColor].opacity(0.5), radius: 5)
                
                // Color picker
                HStack(spacing: 12) {
                    ForEach(0..<signUpModel.avatarColors.count, id: \.self) { index in
                        Circle()
                            .fill(signUpModel.avatarColors[index])
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(signUpModel.selectedAvatarColor == index ? Color.white : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                signUpModel.selectedAvatarColor = index
                            }
                    }
                }
                .padding(.bottom, 10)
            }
            
            // Username field
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(accentColor)
                    .padding(.leading, 10)
                
                TextField("", text: $signUpModel.username)
                    .placeholder(when: signUpModel.username.isEmpty) {
                        Text("Create Username").foregroundColor(.gray.opacity(0.7))
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
            
            // Email field
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(accentColor)
                    .padding(.leading, 10)
                
                TextField("", text: $signUpModel.email)
                    .placeholder(when: signUpModel.email.isEmpty) {
                        Text("Email").foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
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
                
                if signUpModel.showPassword {
                    TextField("", text: $signUpModel.password)
                        .placeholder(when: signUpModel.password.isEmpty) {
                            Text("Password").foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .textContentType(.newPassword)
                } else {
                    SecureField("", text: $signUpModel.password)
                        .placeholder(when: signUpModel.password.isEmpty) {
                            Text("Password").foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .textContentType(.newPassword)
                }
                
                Button(action: {
                    signUpModel.showPassword.toggle()
                }) {
                    Image(systemName: signUpModel.showPassword ? "eye.slash.fill" : "eye.fill")
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
            
            // Confirm Password field with show/hide
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(accentColor)
                    .padding(.leading, 10)
                
                if signUpModel.showConfirmPassword {
                    TextField("", text: $signUpModel.confirmPassword)
                        .placeholder(when: signUpModel.confirmPassword.isEmpty) {
                            Text("Confirm Password").foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                } else {
                    SecureField("", text: $signUpModel.confirmPassword)
                        .placeholder(when: signUpModel.confirmPassword.isEmpty) {
                            Text("Confirm Password").foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    signUpModel.showConfirmPassword.toggle()
                }) {
                    Image(systemName: signUpModel.showConfirmPassword ? "eye.slash.fill" : "eye.fill")
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
            
            // Terms & Privacy
            HStack(alignment: .top, spacing: 10) {
                Button(action: {
                    signUpModel.termsAccepted.toggle()
                }) {
                    Image(systemName: signUpModel.termsAccepted ? "checkmark.square.fill" : "square")
                        .foregroundColor(signUpModel.termsAccepted ? accentColor : .gray)
                }
                
                Text("I agree to the Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 5)
            
            // Continue button
            Button(action: {
                if signUpModel.validateStep1() {
                    withAnimation {
                        signUpModel.currentStep = 2
                    }
                }
            }) {
                Text("Continue")
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
                    .scaleEffect(signUpModel.animateButton ? 0.95 : 1.0)
            }
            .padding(.top, 10)
            .disabled(!signUpModel.termsAccepted)
            .opacity(signUpModel.termsAccepted ? 1.0 : 0.7)
            
            // Back to login
            Button(action: {
                dismiss()
            }) {
                Text("Already have an account? Sign In")
                    .font(.footnote)
                    .foregroundColor(accentColor)
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - Step 2: Personal Info
    private var personalInfoStep: some View {
        VStack(spacing: 20) {
            // Age field
            VStack(alignment: .leading, spacing: 8) {
                Text("Age")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(accentColor)
                        .padding(.leading, 10)
                    
                    TextField("", text: $signUpModel.age)
                        .placeholder(when: signUpModel.age.isEmpty) {
                            Text("Your age").foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                }
                .background(secondaryColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                )
            }
            
            // Gender selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Gender")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Picker("Gender", selection: $signUpModel.gender) {
                    ForEach(SignUpModel.Gender.allCases) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 5)
            }
            
            // Units toggle
            HStack {
                Text("Units")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle(isOn: $signUpModel.useMetricSystem) {
                    Text(signUpModel.useMetricSystem ? "Metric (cm/kg)" : "Imperial (in/lb)")
                        .foregroundColor(.gray)
                }
                .toggleStyle(SwitchToggleStyle(tint: accentColor))
            }
            .padding(.vertical, 5)
            
            // Height field
            VStack(alignment: .leading, spacing: 8) {
                Text("Height")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "ruler")
                        .foregroundColor(accentColor)
                        .padding(.leading, 10)
                    
                    TextField("", text: $signUpModel.height)
                        .placeholder(when: signUpModel.height.isEmpty) {
                            Text(signUpModel.useMetricSystem ? "Height in cm" : "Height in inches").foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                    
                    Text(signUpModel.useMetricSystem ? "cm" : "in")
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
                }
                .background(secondaryColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                )
            }
            
            // Weight field
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "scalemass")
                        .foregroundColor(accentColor)
                        .padding(.leading, 10)
                    
                    TextField("", text: $signUpModel.weight)
                        .placeholder(when: signUpModel.weight.isEmpty) {
                            Text(signUpModel.useMetricSystem ? "Weight in kg" : "Weight in lbs").foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                    
                    Text(signUpModel.useMetricSystem ? "kg" : "lb")
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
                }
                .background(secondaryColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                )
            }
            
            // Navigation buttons
            HStack(spacing: 15) {
                // Back button
                Button(action: {
                    withAnimation {
                        signUpModel.currentStep = 1
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(15)
                }
                
                // Complete sign-up button
                Button(action: {
                    if signUpModel.validateStep2() {
                        withAnimation {
                            signUpModel.animateButton = true
                            
                            // Create user goal from sign-up data
                            var userGoal = signUpModel.completeSignUp()
                            
                            // Set username in the user goal for personalization
                            userGoal.username = signUpModel.username
                            
                            // Save the user goal
                            userGoalViewModel.userGoal = userGoal
                            userGoalViewModel.saveUserGoal()
                            
                            // Save user profile data for app-wide access
                            UserDefaults.standard.set(signUpModel.username, forKey: "username")
                            UserDefaults.standard.set(signUpModel.email, forKey: "userEmail")
                            UserDefaults.standard.set(signUpModel.gender.rawValue, forKey: "userGender")
                            UserDefaults.standard.set(Int(signUpModel.age) ?? 25, forKey: "userAge")
                            
                            // Navigate to main view
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                signUpModel.showingMainView = true
                            }
                        }
                    }
                }) {
                    Text("Create Account")
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
                        .scaleEffect(signUpModel.animateButton ? 0.95 : 1.0)
                }
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Preview

// Preview
struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
