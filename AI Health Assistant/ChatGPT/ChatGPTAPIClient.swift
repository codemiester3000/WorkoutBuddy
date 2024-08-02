import Foundation

class ChatGPTAPIClient {
    
    static let goodModel = "gpt-4o"
    static let badModel = "gpt-3.5-turbo"
    
    static let shared = ChatGPTAPIClient()
    
    private var conversationHistory: [String] = []
    
    private let hardcodedQuestionQuery = "Provide 3 useful questions to ask based on the provided health data. recommended questions are to be formatted as: 1. Question 1 , 2. Question 2, etc."
    
    func sendMessage(_ message: String, model: String = goodModel, temperature: Double = 0.7, includeInConversationHistory: Bool = true, completion: @escaping (String?, Error?) -> Void) {
        
        let endpoint = "https://api.openai.com/v1/chat/completions"
        
        guard let url = URL(string: endpoint) else {
            completion(nil, nil)
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("Bearer \(Environment.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let currentQuery = "User: \(message)"
        let fullConversation = conversationHistory + [currentQuery]
        
        let parameters: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": fullConversation.joined(separator: "\n")]
            ],
            "temperature": temperature
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
            
            // Debug print: Request details
            print("Request URL: \(request.url?.absoluteString ?? "N/A")")
            print("Request Method: \(request.httpMethod ?? "N/A")")
            print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
            if let bodyString = String(data: jsonData, encoding: .utf8) {
                print("Request Body: \(bodyString)")
            }
        } catch {
            completion(nil, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            // Debug print: Response details
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil, nil)
                return
            }
            
            // Debug print: Response body
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Body: \(responseString)")
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   var content = message["content"] as? String {
                    
                    if let hardcodedQuestionQuery = self?.hardcodedQuestionQuery {
                        content = content.replacingOccurrences(of: hardcodedQuestionQuery, with: "")
                    }
                    
                    if includeInConversationHistory {
                        self?.conversationHistory = fullConversation
                        self?.conversationHistory.append("Assistant: \(content)")
                    }
                    completion(content, nil)
                } else {
                    print("Failed to parse response")
                    completion(nil, nil)
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}

struct Environment {
    static let openAIAPIKey: String = {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("API key not set in environment variables")
        }
        return apiKey
    }()
}
