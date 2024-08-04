import Foundation

class QueryHandler {
    private let chatGPTClient = ChatGPTAPIClient()
    private let healthKitHelpers: [String: HealthKitAgent] = [
        "HeartRateData": HeartRateAgent()
        // Add other data type helpers here
    ]
    let activeAgentsManager = ActiveAgentsManager.shared
    
    func handleUserQuery(_ query: String, completion: @escaping (String?, Error?) -> Void) {
        print("handleUserQuery")
        let initialPrompt = QueryHelper.formatPrompt(for: query)
        self.activeAgentsManager.clearActiveDataTypes()
        
        print("sending message")
        chatGPTClient.sendMessage(initialPrompt, includeInConversationHistory: false) { response, error in
            print("\nInitial ChatGPT response: \(String(describing: response))\n")
            if let error = error {
                completion(nil, error)
                return
            }
            
            // The initial response from ChatGPT gives us a list of health agents to use and how far back each
            // one should query for it's data. Once we have fetched the health data, we fire off a second query
            // to chatGPT that asks to answer the initial user query given this provided health data context.
            guard let response = response, let parsedPairs = QueryHelper.parseResponse(response) else {
                print("Error parsing response: \(String(describing: response))")
                completion(nil, NSError(domain: "InvalidResponse", code: 400, userInfo: nil))
                return
            }
            
            print("Parsed pairs: \(parsedPairs)")
            
            self.fetchMultipleData(parsedPairs: parsedPairs) { data, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                // If ChatGPT was not able to repond to the intial query which requested agents. Send
                // the initial query and let ChatGPT respond normaly. This should have the effect of allowing
                // ChatGPT to respond normally
                let finalPrompt: String
                if let data = data {
                    finalPrompt = "\(query)\n\nContextual Data:\n\(data)"
                } else {
                    finalPrompt = query
                }
                
                self.chatGPTClient.sendMessage(finalPrompt, includeInConversationHistory: true) { finalResponse, error in
                    print("\nFinal ChatGPT prompt: \(String(describing: finalPrompt))")
                    print("Final ChatGPT response: \(String(describing: finalResponse))\n")
                    
                    if let error = error {
                        print("Error sending final message: \(error.localizedDescription)") // Debug print statement
                        completion(nil, error)
                        return
                    }
                    
                    completion(finalResponse, error)
                }
            }
        }
    }
    
    private func fetchMultipleData(parsedPairs: [(dataType: String, timestamp: String)], completion: @escaping (String?, Error?) -> Void) {
        let group = DispatchGroup()
        var aggregatedData = ""
        var errors: [Error] = []
        
        for (dataType, numDaysString) in parsedPairs {
            guard let numDays = Int(numDaysString) else {
                print("Invalid number of days: \(numDaysString)") // Debug print statement
                errors.append(NSError(domain: "InvalidNumDays", code: 400, userInfo: nil))
                continue
            }
            
            // Update the singleton agents manager so the UI can know which agents we're querying.
            let dataTypes = parsedPairs.map { $0.dataType }
            self.activeAgentsManager.setActiveDataTypes(dataTypes)
            
            group.enter()
            fetchData(dataType: dataType, numDays: numDays) { data, error in
                if let error = error {
                    print("Error fetching data for \(dataType): \(error.localizedDescription)") // Debug print statement
                    errors.append(error)
                } else if let data = data {
                    aggregatedData += "\(dataType):\n\(data)\n\n"
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if !errors.isEmpty {
                for error in errors {
                    print("Fetch error: \(error.localizedDescription)")
                }
            }
            completion(aggregatedData, nil)
        }
    }
    
    
    private func fetchData(dataType: String, numDays: Int, completion: @escaping (String?, Error?) -> Void) {
        guard let helper = healthKitHelpers[dataType] else {
            print("Unknown data type: \(dataType)") // Debug print statement
            completion(nil, NSError(domain: "UnknownDataType", code: 400, userInfo: nil))
            return
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -numDays, to: endDate) else {
            print("Error calculating start date")
            completion(nil, NSError(domain: "DateCalculationError", code: 400, userInfo: nil))
            return
        }
        
        helper.fetchData(from: startDate, to: endDate, completion: completion)
    }
}
