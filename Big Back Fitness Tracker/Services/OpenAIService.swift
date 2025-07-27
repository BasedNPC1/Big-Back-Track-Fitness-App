import Foundation
import Combine

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        self.apiKey = EnvironmentConfig.openAIApiKey
    }
    
    // Model for OpenAI request
    struct OpenAIRequest: Codable {
        let model: String
        let messages: [Message]
        let temperature: Double
        
        struct Message: Codable {
            let role: String
            let content: String
        }
    }
    
    // Model for OpenAI response
    struct OpenAIResponse: Codable {
        let id: String
        let object: String
        let created: Int
        let model: String
        let choices: [Choice]
        
        struct Choice: Codable {
            let index: Int
            let message: Message
            let finishReason: String
            
            enum CodingKeys: String, CodingKey {
                case index
                case message
                case finishReason = "finish_reason"
            }
        }
        
        struct Message: Codable {
            let role: String
            let content: String
        }
    }
    
    // Nutrition data model
    struct NutritionData {
        let protein: Double
        let fat: Double
        let carbs: Double
        let calories: Double
        let totalSugars: Double
        let fiber: Double
        let calcium: Double
        let iron: Double
        let sodium: Double
        let vitaminA: Double
        let vitaminC: Double
        let cholesterol: Double
    }
    
    // Simplified nutrition data model for goal calculations
    struct GoalNutritionData {
        let calories: Double
        let macros: MacroNutrients
        
        struct MacroNutrients {
            let protein: Double
            let carbs: Double
            let fat: Double
        }
    }
    
    // Function to extract JSON data from a string
    private func extractJSONData(from content: String) -> Data? {
        // Check for JSON object pattern
        let pattern = "\\{[\\s\\S]*?\\}"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count)) {
            let range = match.range
            if let swiftRange = Range(range, in: content) {
                let jsonString = String(content[swiftRange])
                return jsonString.data(using: .utf8)
            }
        }
        
        return nil
    }
    
    // Function to get nutrition data for goal calculations
    func getNutritionData(prompt: String, completion: @escaping (Result<GoalNutritionData, Error>) -> Void) {
        // Create URL request
        guard let url = URL(string: baseURL) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create the OpenAI request
        let openAIRequest = OpenAIRequest(
            model: "gpt-4o",
            messages: [
                OpenAIRequest.Message(role: "system", content: "You are a nutrition and fitness expert assistant. Provide nutrition goal calculations in JSON format only."),
                OpenAIRequest.Message(role: "user", content: prompt)
            ],
            temperature: 0.7
        )
        
        // Encode the request
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(openAIRequest)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Create the data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                // Decode the OpenAI response
                let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                
                // Extract the content from the response
                guard let content = openAIResponse.choices.first?.message.content else {
                    completion(.failure(NSError(domain: "OpenAIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                    return
                }
                
                // Extract JSON from the content
                if let jsonData = self.extractJSONData(from: content) {
                    do {
                        // Parse the JSON data
                        if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let calories = json["dailyCalories"] as? Double,
                           let protein = json["dailyProtein"] as? Double,
                           let carbs = json["dailyCarbs"] as? Double,
                           let fat = json["dailyFat"] as? Double {
                            
                            // Create the nutrition data object
                            let macros = GoalNutritionData.MacroNutrients(protein: protein, carbs: carbs, fat: fat)
                            let nutritionData = GoalNutritionData(calories: calories, macros: macros)
                            
                            completion(.success(nutritionData))
                        } else {
                            completion(.failure(NSError(domain: "OpenAIService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing required fields in JSON response"])))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NSError(domain: "OpenAIService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not extract JSON from response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // Function to get nutrition data for a food item
    func getNutritionData(for food: String, weight: Double, unit: String) -> AnyPublisher<NutritionData, Error> {
        // Create URL request
        guard let url = URL(string: baseURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create the prompt for OpenAI
        let prompt = """
        I need nutritional information for \(weight) \(unit) of \(food).
        Please provide the following nutritional values in a JSON format:
        - protein (g)
        - fat (g)
        - carbs (g)
        - calories (kcal)
        - totalSugars (g)
        - fiber (g)
        - calcium (mg)
        - iron (mg)
        - sodium (mg)
        - vitaminA (IU)
        - vitaminC (mg)
        - cholesterol (mg)
        
        Format your response as valid JSON only, with no additional text:
        {
          "protein": 0.0,
          "fat": 0.0,
          "carbs": 0.0,
          "calories": 0.0,
          "totalSugars": 0.0,
          "fiber": 0.0,
          "calcium": 0.0,
          "iron": 0.0,
          "sodium": 0.0,
          "vitaminA": 0.0,
          "vitaminC": 0.0,
          "cholesterol": 0.0
        }
        """
        
        // Create the request body
        let requestBody = OpenAIRequest(
            model: "gpt-4",
            messages: [
                OpenAIRequest.Message(role: "system", content: "You are a nutrition database assistant. Provide accurate nutritional information in JSON format only."),
                OpenAIRequest.Message(role: "user", content: prompt)
            ],
            temperature: 0.2
        )
        
        // Encode the request body
        guard let httpBody = try? JSONEncoder().encode(requestBody) else {
            return Fail(error: URLError(.cannotParseResponse)).eraseToAnyPublisher()
        }
        
        request.httpBody = httpBody
        
        // Make the request
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: OpenAIResponse.self, decoder: JSONDecoder())
            .map { response -> NutritionData in
                // Parse the JSON response from OpenAI
                guard let content = response.choices.first?.message.content,
                      let jsonData = content.data(using: .utf8) else {
                    // Return default values if parsing fails
                    return self.defaultNutritionData()
                }
                
                do {
                    // Try to parse the JSON content
                    if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Double] {
                        return NutritionData(
                            protein: json["protein"] ?? 0.0,
                            fat: json["fat"] ?? 0.0,
                            carbs: json["carbs"] ?? 0.0,
                            calories: json["calories"] ?? 0.0,
                            totalSugars: json["totalSugars"] ?? 0.0,
                            fiber: json["fiber"] ?? 0.0,
                            calcium: json["calcium"] ?? 0.0,
                            iron: json["iron"] ?? 0.0,
                            sodium: json["sodium"] ?? 0.0,
                            vitaminA: json["vitaminA"] ?? 0.0,
                            vitaminC: json["vitaminC"] ?? 0.0,
                            cholesterol: json["cholesterol"] ?? 0.0
                        )
                    }
                } catch {
                    print("Error parsing nutrition data: \(error)")
                }
                
                // Return default values if parsing fails
                return self.defaultNutritionData()
            }
            .eraseToAnyPublisher()
    }
    
    // Default nutrition data for fallback
    private func defaultNutritionData() -> NutritionData {
        return NutritionData(
            protein: 0.0,
            fat: 0.0,
            carbs: 0.0,
            calories: 0.0,
            totalSugars: 0.0,
            fiber: 0.0,
            calcium: 0.0,
            iron: 0.0,
            sodium: 0.0,
            vitaminA: 0.0,
            vitaminC: 0.0,
            cholesterol: 0.0
        )
    }
}
