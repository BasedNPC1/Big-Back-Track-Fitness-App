import SwiftUI

struct FoodLogView: View {
    @ObservedObject var viewModel: FoodLogViewModel
    @State private var showingAddFood = false
    @State private var showingSetGoal = false
    @State private var newFoodName = ""
    @State private var newFoodWeight = 100.0
    @State private var selectedUnit = "g"
    @State private var showingSuccessMessage = false
    @State private var successMessage = ""
    
    // Colors for the vibrant theme (matching LoginView)
    let darkBackground = Color.black
    let gradientStart = Color(red: 0.0, green: 0.8, blue: 0.8) // Teal
    let gradientEnd = Color(red: 0.5, green: 0.0, blue: 0.8) // Purple
    let accentColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    let secondaryColor = Color(red: 0.15, green: 0.15, blue: 0.2) // Dark blue-gray
    let redColor = Color.red
    
    // Available units
    let units = ["g", "oz", "ml", "cup", "tbsp"]
    
    var body: some View {
        ZStack {
            // Background
            darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        
                        Text("LOG FOOD")
                            .font(.custom("Montserrat-Bold", size: 28, relativeTo: .title))
                            .fontWeight(.black)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [gradientStart, gradientEnd], 
                                    startPoint: .leading, 
                                    endPoint: .trailing
                                )
                            )
                        
                        Spacer()
                        
                        // Set Goal button
                        Button(action: {
                            showingSetGoal = true
                        }) {
                            Image(systemName: "target")
                                .font(.system(size: 22))
                                .foregroundColor(accentColor)
                                .padding(8)
                                .background(Circle().fill(secondaryColor))
                        }
                    }
                    
                    // Search bar or Add Food button
                    Button(action: {
                        showingAddFood = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(accentColor)
                            Text("Add Food")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(secondaryColor)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Success message or error message (if shown)
                if showingSuccessMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(accentColor)
                        Text(successMessage)
                            .foregroundColor(accentColor)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(secondaryColor)
                    .cornerRadius(8)
                    .padding(.bottom, 10)
                } else if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(redColor)
                        Text(errorMessage)
                            .foregroundColor(redColor)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(secondaryColor)
                    .cornerRadius(8)
                    .padding(.bottom, 10)
                }
                
                // Food log list
                if viewModel.foodEntries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No foods logged yet")
                            .foregroundColor(.gray)
                            .font(.headline)
                        Text("Add your first food item to start tracking")
                            .foregroundColor(.gray.opacity(0.7))
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.foodEntries) { entry in
                            FoodEntryRow(
                                entry: entry, 
                                isExpanded: viewModel.showingDetails.contains(entry.id),
                                accentColor: accentColor,
                                secondaryColor: secondaryColor,
                                redColor: redColor,
                                onToggle: {
                                    viewModel.toggleDetails(for: entry.id)
                                }
                            )
                            .listRowBackground(Color.black)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: viewModel.removeEntry)
                    }
                    .listStyle(.plain)
                }
                
                // Motivational message at the bottom
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(redColor)
                    Text("Okay fine, this is clean... but you're still soft.")
                        .font(.caption)
                        .foregroundColor(redColor)
                }
                .padding(.vertical, 10)
            }
            .sheet(isPresented: $showingAddFood) {
                addFoodView
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingSetGoal) {
                SetGoalView(foodLogViewModel: viewModel)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Add Food Sheet View
    var addFoodView: some View {
        VStack(spacing: 20) {
            Text("Enter Food Details")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter food (e.g. chicken breast, banana):")
                    .foregroundColor(.gray)
                    .font(.caption)
                
                TextField("", text: $newFoodName)
                    .padding()
                    .background(secondaryColor)
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                // Weight input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    HStack {
                        TextField("", value: $newFoodWeight, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(secondaryColor)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                newFoodWeight = max(0, newFoodWeight - 10)
                            }) {
                                Text("-")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                            }
                            
                            Button(action: {
                                newFoodWeight += 10
                            }) {
                                Text("+")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                            }
                        }
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                    }
                }
                
                // Unit selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Unit")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Menu {
                        ForEach(units, id: \.self) { unit in
                            Button(unit) {
                                selectedUnit = unit
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedUnit)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(width: 100)
                        .background(secondaryColor)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                // Add the food entry
                if !newFoodName.isEmpty {
                    viewModel.addFoodEntry(name: newFoodName, weight: newFoodWeight, unit: selectedUnit)
                    
                    // Show success message
                    successMessage = "Added \(newFoodName.uppercased()) (\(newFoodWeight)\(selectedUnit))"
                    showingSuccessMessage = true
                    
                    // Hide success message after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showingSuccessMessage = false
                        }
                    }
                    
                    // Reset fields
                    newFoodName = ""
                    newFoodWeight = 100.0
                    selectedUnit = "g"
                    
                    // Dismiss sheet
                    showingAddFood = false
                }
            }) {
                if viewModel.isLoading {
                    HStack {
                        SwiftUI.ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Analyzing with AI...")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.0, green: 0.5, blue: 0.8).opacity(0.7), Color(red: 0.0, green: 0.4, blue: 0.7).opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                } else {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        Text("Get AI Nutrition Data")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.0, green: 0.5, blue: 0.8), Color(red: 0.0, green: 0.4, blue: 0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .disabled(newFoodName.isEmpty || viewModel.isLoading)
            .opacity((newFoodName.isEmpty || viewModel.isLoading) ? 0.6 : 1)
            
            Spacer()
        }
        .background(Color.black)
    }
}

// Food Entry Row Component
struct FoodEntryRow: View {
    let entry: FoodLogEntry
    let isExpanded: Bool
    let accentColor: Color
    let secondaryColor: Color
    let redColor: Color
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main row with timestamp and macros
            HStack {
                // Timestamp column
                VStack(alignment: .leading) {
                    Text(formattedTime(from: entry.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(entry.foodName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(String(format: "%.1f", entry.weight))\(entry.unit)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(width: 120, alignment: .leading)
                
                Spacer()
                
                // Macros column
                VStack(alignment: .trailing, spacing: 2) {
                    MacroRow(label: "Protein", value: entry.macros.protein, unit: "g")
                    MacroRow(label: "Fat", value: entry.macros.fat, unit: "g")
                    MacroRow(label: "Carbs", value: entry.macros.carbs, unit: "g")
                    MacroRow(label: "Calories", value: entry.macros.calories, unit: "kcal")
                }
                
                // Expand/collapse button
                Button(action: onToggle) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
            }
            .padding()
            .background(secondaryColor)
            .cornerRadius(12)
            
            // Expanded micros section
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Micronutrients")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(accentColor)
                    
                    // Grid of micros
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        MicroRow(label: "Sugars", value: entry.micros.totalSugars, unit: "g")
                        MicroRow(label: "Fiber", value: entry.micros.fiber, unit: "g")
                        MicroRow(label: "Calcium", value: entry.micros.calcium, unit: "mg")
                        MicroRow(label: "Iron", value: entry.micros.iron, unit: "mg")
                        MicroRow(label: "Sodium", value: entry.micros.sodium, unit: "mg")
                        MicroRow(label: "Vitamin A", value: entry.micros.vitaminA, unit: "IU")
                        MicroRow(label: "Vitamin C", value: entry.micros.vitaminC, unit: "mg")
                        MicroRow(label: "Cholesterol", value: entry.micros.cholesterol, unit: "mg")
                    }
                }
                .padding()
                .background(secondaryColor.opacity(0.5))
                .cornerRadius(12)
            }
        }
    }
    
    // Format time to HH:MM
    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// Macro Row Component
struct MacroRow: View {
    let label: String
    let value: Double
    let unit: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.gray)
            Text("\(String(format: "%.1f", value))\(unit)")
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

// Micro Row Component
struct MicroRow: View {
    let label: String
    let value: Double
    let unit: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text("\(String(format: "%.1f", value))\(unit)")
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    FoodLogView(viewModel: FoodLogViewModel())
}
