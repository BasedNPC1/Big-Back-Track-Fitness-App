import Foundation
import SwiftUI
import Combine

// Model for food log entries
struct FoodLogEntry: Identifiable {
    let id = UUID()
    let foodName: String
    let timestamp: Date
    let weight: Double
    let unit: String
    let macros: MacroNutrients
    let micros: MicroNutrients
    
    // For mock data
    static func mockEntry() -> FoodLogEntry {
        return FoodLogEntry(
            foodName: "CHICKEN BREAST",
            timestamp: Date(),
            weight: 100.0,
            unit: "g",
            macros: MacroNutrients(protein: 20.4, fat: 12.7, carbs: 1.1, calories: 165.0),
            micros: MicroNutrients(
                totalSugars: 0.7,
                fiber: 0.0,
                calcium: 158.0,
                iron: 0.4,
                sodium: 433.0,
                vitaminA: 352.0,
                vitaminC: 1.7,
                cholesterol: 67.0
            )
        )
    }
}

// Macro nutrients structure
struct MacroNutrients {
    let protein: Double
    let fat: Double
    let carbs: Double
    let calories: Double
}

// Micro nutrients structure
struct MicroNutrients {
    let totalSugars: Double
    let fiber: Double
    let calcium: Double
    let iron: Double
    let sodium: Double
    let vitaminA: Double
    let vitaminC: Double
    let cholesterol: Double
}

// View model for food logging
class FoodLogViewModel: ObservableObject {
    @Published var foodEntries: [FoodLogEntry] = []
    @Published var searchQuery: String = ""
    @Published var weight: Double = 100.0
    @Published var unit: String = "g"
    @Published var showingDetails: Set<UUID> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let openAIService = OpenAIService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Add mock data
        let calendar = Calendar.current
        let now = Date()
    }
    
    func addFoodEntry(name: String, weight: Double, unit: String) {
        // Set loading state
        isLoading = true
        errorMessage = nil
        
        // Check if we're using a placeholder API key
        if EnvironmentConfig.openAIApiKey == "YOUR_OPENAI_API_KEY_HERE" {
            // Use mock data if API key is not set
            createMockFoodEntry(name: name, weight: weight, unit: unit)
            isLoading = false
            return
        }
        
        // Call OpenAI API to get nutritional data
        openAIService.getNutritionData(for: name, weight: weight, unit: unit)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                    print("Error fetching nutrition data: \(error)")
                    
                    // Fallback to mock data on error
                    self?.createMockFoodEntry(name: name, weight: weight, unit: unit)
                }
            }, receiveValue: { [weak self] nutritionData in
                guard let self = self else { return }
                
                // Create macros and micros from API data
                let macros = MacroNutrients(
                    protein: nutritionData.protein,
                    fat: nutritionData.fat,
                    carbs: nutritionData.carbs,
                    calories: nutritionData.calories
                )
                
                let micros = MicroNutrients(
                    totalSugars: nutritionData.totalSugars,
                    fiber: nutritionData.fiber,
                    calcium: nutritionData.calcium,
                    iron: nutritionData.iron,
                    sodium: nutritionData.sodium,
                    vitaminA: nutritionData.vitaminA,
                    vitaminC: nutritionData.vitaminC,
                    cholesterol: nutritionData.cholesterol
                )
                
                // Create and add the new food entry
                let newEntry = FoodLogEntry(
                    foodName: name.uppercased(),
                    timestamp: Date(),
                    weight: weight,
                    unit: unit,
                    macros: macros,
                    micros: micros
                )
                
                self.foodEntries.insert(newEntry, at: 0)
            })
            .store(in: &cancellables)
    }
    
    // Fallback function to create mock food entry
    private func createMockFoodEntry(name: String, weight: Double, unit: String) {
        let mockMacros = MacroNutrients(protein: 20.4, fat: 12.7, carbs: 1.1, calories: 165.0)
        let mockMicros = MicroNutrients(
            totalSugars: 0.7,
            fiber: 0.0,
            calcium: 158.0,
            iron: 0.4,
            sodium: 433.0,
            vitaminA: 352.0,
            vitaminC: 1.7,
            cholesterol: 67.0
        )
        
        let newEntry = FoodLogEntry(
            foodName: name.uppercased(),
            timestamp: Date(),
            weight: weight,
            unit: unit,
            macros: mockMacros,
            micros: mockMicros
        )
        
        foodEntries.insert(newEntry, at: 0)
    }
    
    func toggleDetails(for id: UUID) {
        if showingDetails.contains(id) {
            showingDetails.remove(id)
        } else {
            showingDetails.insert(id)
        }
    }
    
    func removeEntry(at indexSet: IndexSet) {
        foodEntries.remove(atOffsets: indexSet)
    }
    
    // Fetch food entries from persistent storage
    func fetchFoodEntries() {
        // In a real app, this would load from a database or UserDefaults
        // For now, we'll just ensure we have the latest entries
        // This method can be expanded later to load from persistent storage
        
        // If using UserDefaults in the future, implementation would be:
        // if let savedData = UserDefaults.standard.data(forKey: "foodEntries") {
        //     do {
        //         let decoder = JSONDecoder()
        //         self.foodEntries = try decoder.decode([FoodLogEntry].self, from: savedData)
        //     } catch {
        //         print("Error loading food entries: \(error)")
        //     }
        // }
    }
}
