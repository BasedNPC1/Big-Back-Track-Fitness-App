import Foundation

enum EnvironmentConfig {
    // Hardcoded API key for development
    static var openAIApiKey: String {
        // IMPORTANT: This is a temporary solution for local development
        // In a production app, you would store this securely
        return "YOUR_OPENAI_API_KEY_HERE"
    }
}
