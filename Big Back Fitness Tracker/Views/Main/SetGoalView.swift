import SwiftUI

struct SetGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = UserGoalViewModel()
    @ObservedObject var foodLogViewModel: FoodLogViewModel
    
    // User inputs
    @State private var height: Double = 170.0
    @State private var heightString: String = "170.0"
    @State private var weight: Double = 70.0
    @State private var weightString: String = "70.0"
    @State private var age: Int = 30
    @State private var ageString: String = "30"
    @State private var gender: UserGoal.Gender = .male
    @State private var targetWeight: Double = 65.0
    @State private var targetWeightString: String = "65.0"
    @State private var timeframe: Int = 12
    @State private var timeframeString: String = "12"
    @State private var bodyFat: String = ""
    
    // Unit selection
    @State private var heightUnit: HeightUnit = .cm
    @State private var weightUnit: WeightUnit = .kg
    
    // Unit enums
    enum HeightUnit: String, CaseIterable, Identifiable {
        case cm = "cm"
        case feet = "ft/in"
        
        var id: String { self.rawValue }
    }
    
    enum WeightUnit: String, CaseIterable, Identifiable {
        case kg = "kg"
        case lbs = "lbs"
        
        var id: String { self.rawValue }
    }
    
    // UI states
    @State private var showingResults = false
    
    // Colors for the vibrant theme (matching LoginView and FoodLogView)
    let darkBackground = Color.black
    let gradientStart = Color(red: 0.0, green: 0.8, blue: 0.8) // Teal
    let gradientEnd = Color(red: 0.5, green: 0.0, blue: 0.8) // Purple
    let accentColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    let secondaryColor = Color(red: 0.15, green: 0.15, blue: 0.2) // Dark blue-gray
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                darkBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Text("SET YOUR GOALS")
                            .font(.custom("Montserrat-Bold", size: 28, relativeTo: .title))
                            .fontWeight(.black)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [gradientStart, gradientEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.top, 20)
                        
                        if showingResults && viewModel.userGoal != nil {
                            // Results section
                            resultsView
                        } else {
                            // Input form
                            inputForm
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(secondaryColor))
                }
            )
        }
    }
    
    // Input form view
    private var inputForm: some View {
        VStack(spacing: 20) {
            Group {
                // Height input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Height")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        // Unit selector
                        Picker("", selection: $heightUnit) {
                            ForEach(HeightUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                        .onChange(of: heightUnit) { newUnit in
                            // Convert height when unit changes
                            if newUnit == .feet && heightUnit == .cm {
                                // Convert cm to feet/inches
                                let totalInches = height / 2.54
                                let feet = Int(totalInches / 12)
                                let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
                                heightString = "\(feet)'\(inches)\""
                            } else if newUnit == .cm && heightUnit == .feet {
                                // Parse feet/inches and convert to cm
                                if let cmValue = convertFeetInchesToCm(heightString) {
                                    height = cmValue
                                    heightString = String(format: "%.1f", height)
                                }
                            }
                        }
                    }
                    
                    HStack(spacing: 10) {
                        // Slider
                        Slider(value: $height, in: heightUnit == .cm ? 120...220 : 47...87, step: heightUnit == .cm ? 1 : 0.5) { _ in
                            // Update text field when slider changes
                            heightString = String(format: "%.1f", height)
                        }
                        .accentColor(accentColor)
                        
                        // Text field for manual entry
                        TextField("", text: $heightString)
                            .keyboardType(heightUnit == .cm ? .decimalPad : .default)
                            .multilineTextAlignment(.trailing)
                            .padding(8)
                            .background(secondaryColor)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .frame(width: 80)
                            .onChange(of: heightString) { newValue in
                                if heightUnit == .cm {
                                    if let value = Double(newValue) {
                                        height = value
                                    }
                                } else {
                                    if let cmValue = convertFeetInchesToCm(newValue) {
                                        height = cmValue
                                    }
                                }
                            }
                    }
                }
                
                // Weight input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Current Weight")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        // Unit selector
                        Picker("", selection: $weightUnit) {
                            ForEach(WeightUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                        .onChange(of: weightUnit) { newUnit in
                            // Convert weight when unit changes
                            if newUnit == .lbs && weightUnit == .kg {
                                // Convert kg to lbs
                                weight = weight * 2.20462
                                weightString = String(format: "%.1f", weight)
                            } else if newUnit == .kg && weightUnit == .lbs {
                                // Convert lbs to kg
                                weight = weight / 2.20462
                                weightString = String(format: "%.1f", weight)
                            }
                        }
                    }
                    
                    HStack(spacing: 10) {
                        // Slider
                        Slider(value: $weight, in: weightUnit == .kg ? 40...200 : 88...440, step: 0.5) { _ in
                            // Update text field when slider changes
                            weightString = String(format: "%.1f", weight)
                        }
                        .accentColor(accentColor)
                        
                        // Text field for manual entry
                        TextField("", text: $weightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .padding(8)
                            .background(secondaryColor)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .frame(width: 80)
                            .onChange(of: weightString) { newValue in
                                if let value = Double(newValue) {
                                    weight = value
                                }
                            }
                    }
                }
                
                // Age input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 10) {
                        // Slider
                        Slider(value: Binding(
                            get: { Double(age) },
                            set: { age = Int($0) }
                        ), in: 18...100, step: 1) { _ in
                            // Update text field when slider changes
                            ageString = "\(age)"
                        }
                        .accentColor(accentColor)
                        
                        // Text field for manual entry
                        TextField("", text: $ageString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .padding(8)
                            .background(secondaryColor)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .frame(width: 80)
                            .onChange(of: ageString) { newValue in
                                if let value = Int(newValue) {
                                    age = value
                                }
                            }
                    }
                }
                
                // Gender selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gender")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(UserGoal.Gender.allCases) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(secondaryColor)
                }
            }
            
            Group {
                // Target weight input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Weight")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 10) {
                        // Slider
                        Slider(value: $targetWeight, in: weightUnit == .kg ? 40...200 : 88...440, step: 0.5) { _ in
                            // Update text field when slider changes
                            targetWeightString = String(format: "%.1f", targetWeight)
                        }
                        .accentColor(accentColor)
                        
                        // Text field for manual entry
                        TextField("", text: $targetWeightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .padding(8)
                            .background(secondaryColor)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .frame(width: 80)
                            .onChange(of: targetWeightString) { newValue in
                                if let value = Double(newValue) {
                                    targetWeight = value
                                }
                            }
                    }
                }
                
                // Timeframe input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Timeframe (weeks)")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 10) {
                        // Slider
                        Slider(value: Binding(
                            get: { Double(timeframe) },
                            set: { timeframe = Int($0) }
                        ), in: 4...52, step: 1) { _ in
                            // Update text field when slider changes
                            timeframeString = "\(timeframe)"
                        }
                        .accentColor(accentColor)
                        
                        // Text field for manual entry
                        TextField("", text: $timeframeString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .padding(8)
                            .background(secondaryColor)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .frame(width: 80)
                            .onChange(of: timeframeString) { newValue in
                                if let value = Int(newValue) {
                                    timeframe = value
                                }
                            }
                    }
                }
                
                // Body fat input (optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Body Fat % (optional)")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    TextField("Enter body fat %", text: $bodyFat)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(secondaryColor)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
            
            // Calculate button
            Button(action: calculateGoals) {
                if viewModel.isLoading {
                    HStack {
                        SwiftUI.ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Calculating...")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [accentColor.opacity(0.7), accentColor.opacity(0.5)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                } else {
                    Text("CALCULATE MY GOALS")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [accentColor, accentColor.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
            }
            .disabled(viewModel.isLoading)
            .padding(.top, 10)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding(.vertical)
    }
    
    // Results view
    private var resultsView: some View {
        VStack(spacing: 25) {
            // Weight goal summary
            VStack(spacing: 10) {
                Text("YOUR GOAL")
                    .font(.headline)
                    .foregroundColor(accentColor)
                
                HStack(spacing: 15) {
                    VStack(alignment: .center) {
                        Text("CURRENT")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(formatWeightForDisplay(weight))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Image(systemName: "arrow.right")
                        .font(.title3)
                        .foregroundColor(accentColor)
                    
                    VStack(alignment: .center) {
                        Text("TARGET")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(formatWeightForDisplay(targetWeight))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Image(systemName: "calendar")
                        .font(.title3)
                        .foregroundColor(accentColor)
                    
                    VStack(alignment: .center) {
                        Text("TIMEFRAME")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(timeframe) weeks")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(secondaryColor)
                .cornerRadius(15)
            }
            
            // Daily nutrition goals
            VStack(spacing: 15) {
                Text("DAILY NUTRITION GOALS")
                    .font(.headline)
                    .foregroundColor(accentColor)
                
                // Calories
                HStack {
                    Text("Calories")
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(viewModel.userGoal?.dailyCalories ?? 0) kcal")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .background(secondaryColor)
                .cornerRadius(10)
                
                // Protein
                HStack {
                    Text("Protein")
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(viewModel.userGoal?.dailyProtein ?? 0)) g")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .background(secondaryColor)
                .cornerRadius(10)
                
                // Carbs
                HStack {
                    Text("Carbohydrates")
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(viewModel.userGoal?.dailyCarbs ?? 0)) g")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .background(secondaryColor)
                .cornerRadius(10)
                
                // Fat
                HStack {
                    Text("Fat")
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(viewModel.userGoal?.dailyFat ?? 0)) g")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .background(secondaryColor)
                .cornerRadius(10)
            }
            
            // Motivational message
            Text("💪 YOU GOT THIS! STAY CONSISTENT AND CRUSH YOUR GOALS! 🔥")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(accentColor)
                .padding()
            
            // Reset button
            Button(action: {
                showingResults = false
            }) {
                Text("SET NEW GOAL")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [gradientStart, gradientEnd]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(20)
        .padding(.vertical)
    }
    
    // Format weight for display based on selected unit
    private func formatWeightForDisplay(_ weightValue: Double) -> String {
        if weightUnit == .kg {
            return "\(String(format: "%.1f", weightValue)) kg"
        } else {
            return "\(String(format: "%.1f", weightValue)) lbs"
        }
    }
    
    // Function to convert feet/inches format to cm
    private func convertFeetInchesToCm(_ feetInchesString: String) -> Double? {
        // Parse feet and inches from string like "5'10"
        let regex = try? NSRegularExpression(pattern: "(\\d+)'(\\d+)", options: [])
        if let match = regex?.firstMatch(in: feetInchesString, options: [], range: NSRange(location: 0, length: feetInchesString.count)) {
            if let feetRange = Range(match.range(at: 1), in: feetInchesString),
               let inchesRange = Range(match.range(at: 2), in: feetInchesString),
               let feet = Int(feetInchesString[feetRange]),
               let inches = Int(feetInchesString[inchesRange]) {
                
                let totalInches = Double(feet * 12 + inches)
                return totalInches * 2.54 // Convert inches to cm
            }
        }
        
        // Try alternative format like "5 10" (feet and inches with space)
        let spaceRegex = try? NSRegularExpression(pattern: "(\\d+)\\s+(\\d+)", options: [])
        if let match = spaceRegex?.firstMatch(in: feetInchesString, options: [], range: NSRange(location: 0, length: feetInchesString.count)) {
            if let feetRange = Range(match.range(at: 1), in: feetInchesString),
               let inchesRange = Range(match.range(at: 2), in: feetInchesString),
               let feet = Int(feetInchesString[feetRange]),
               let inches = Int(feetInchesString[inchesRange]) {
                
                let totalInches = Double(feet * 12 + inches)
                return totalInches * 2.54 // Convert inches to cm
            }
        }
        
        // Try just feet (single number)
        if let feet = Int(feetInchesString) {
            return Double(feet * 12) * 2.54
        }
        
        return nil
    }
    
    // Calculate goals function
    private func calculateGoals() {
        // Convert values based on selected units
        var heightInCm = height
        var weightInKg = weight
        var targetWeightInKg = targetWeight
        
        // Convert height if needed
        if heightUnit == .feet {
            heightInCm = height * 2.54 // Convert inches to cm
        }
        
        // Convert weights if needed
        if weightUnit == .lbs {
            weightInKg = weight / 2.20462 // Convert lbs to kg
            targetWeightInKg = targetWeight / 2.20462 // Convert lbs to kg
        }
        
        // Convert optional body fat string to Double
        let bodyFatValue: Double? = Double(bodyFat.isEmpty ? "0" : bodyFat)
        
        // Call view model to calculate goals
        viewModel.calculateGoals(
            height: heightInCm,
            weight: weightInKg,
            age: age,
            gender: gender,
            targetWeight: targetWeightInKg,
            timeframe: timeframe,
            bodyFat: bodyFatValue
        )
        
        // Show results after calculation
        showingResults = true
    }
} 

#Preview {
    SetGoalView(foodLogViewModel: FoodLogViewModel())
}
