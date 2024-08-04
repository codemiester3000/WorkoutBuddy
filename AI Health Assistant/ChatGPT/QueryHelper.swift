import Foundation

class QueryHelper {
    
    private let agents: [HealthKitAgent] = [HeartRateAgent(), WorkoutsAgent()]
    
    static func parseResponse(_ response: String) -> [(dataType: String, timestamp: String)]? {
            // Create a character set with allowed characters: agent names, commas, semicolons, and numbers
            let allowedCharacters = CharacterSet(charactersIn: "0123456789,;")
            let agentNames = ["HeartRateData", "SleepData", "WorkoutData", "StepData"]
            
            // Combine the allowed characters with the characters from agent names
            let agentNameCharacters = CharacterSet(charactersIn: agentNames.joined())
            let finalAllowedCharacters = allowedCharacters.union(agentNameCharacters)
            
            // Filter the response to include only allowed characters
            let filteredResponse = response.unicodeScalars.filter { finalAllowedCharacters.contains($0) }
            let cleanedResponse = String(String.UnicodeScalarView(filteredResponse))
            
            // Split the cleaned response into pairs
            let pairs = cleanedResponse.split(separator: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            var result: [(dataType: String, timestamp: String)] = []
            
            for pair in pairs {
                let components = pair.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                guard components.count == 2 else {
                    print("Invalid pair format: \(pair)")
                    return nil
                }
                
                let dataType = components[0]
                let timestamp = components[1]
                
                result.append((dataType, timestamp))
            }
            
            print("pairs: ", pairs)
            return result
        }
    
    static func formatPrompt(for query: String) -> String {
        """
        [STRUCTURED_RESPONSE_START]
        FORMAT: <dataType>,<num_days_look_back>; <dataType>,<num_days_look_back>; ...
        TIMESTAMP FORMAT: positive integer
        VALID DATATYPES: HeartRateData, SleepData, WorkoutData, StepData

        USER QUERY: "\(query)"

        INSTRUCTIONS: Based on the user query, provide multiple dataType and the number of days back to search. Use only the specified format and valid dataTypes. The number of days should be based on the user query. If the user says 1 month, the number of days should be 30 days back from today.
        [STRUCTURED_RESPONSE_END]

        IMPORTANT: After this initial structured response, please respond normally to all subsequent queries without any special formatting.
        """
    }
}

