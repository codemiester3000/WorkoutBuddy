import Foundation

class QueryHandler {
    private let chatGPTClient = ChatGPTAPIClient()
    private let healthKitHelpers: [String: HealthKitFetcher] = [
        "HeartRateData": HeartRateAgent()
        // Add other data type helpers here
    ]
    
    func handleUserQuery(_ query: String, completion: @escaping (String?, Error?) -> Void) {
        print("handleUserQuery")
        let initialPrompt = QueryHelper.formatPrompt(for: query)
        
        print("sending message")
        chatGPTClient.sendMessage(initialPrompt, includeInConversationHistory: false) { response, error in
            print("Initial ChatGPT response: \(String(describing: response))") // Debug print statement
            if let error = error {
                print("Error sending initial message: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let response = response, let parsedPairs = QueryHelper.parseResponse(response) else {
                print("Error parsing response: \(String(describing: response))") // Debug print statement
                completion(nil, NSError(domain: "InvalidResponse", code: 400, userInfo: nil))
                return
            }
            
            print("Parsed pairs: \(parsedPairs)") // Debug print statement
            
            self.fetchMultipleData(parsedPairs: parsedPairs) { data, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                guard let data = data else {
                    print("No data fetched")
                    completion(nil, NSError(domain: "NoData", code: 400, userInfo: nil))
                    return
                }
                
                let finalPrompt = "\(query)\n\nContextual Data:\n\(data)"
                print("Final prompt: \(finalPrompt)")
                
                self.chatGPTClient.sendMessage(finalPrompt, includeInConversationHistory: true) { finalResponse, error in
                    if let error = error {
                        print("Error sending final message: \(error.localizedDescription)") // Debug print statement
                        completion(nil, error)
                        return
                    }
                    
                    print("Final ChatGPT response: \(String(describing: finalResponse))") // Debug print statement
                    completion(finalResponse, error)
                }
            }
        }
    }
    
    private func fetchMultipleData(parsedPairs: [(dataType: String, timestamp: String)], completion: @escaping (String?, Error?) -> Void) {
        let group = DispatchGroup()
        var aggregatedData = ""
        var fetchError: Error?
        
        for (dataType, numDaysString) in parsedPairs {
            guard let numDays = Int(numDaysString) else {
                print("Invalid number of days: \(numDaysString)") // Debug print statement
                fetchError = NSError(domain: "InvalidNumDays", code: 400, userInfo: nil)
                break
            }
            
            group.enter()
            fetchData(dataType: dataType, numDays: numDays) { data, error in
                if let error = error {
                    print("Error fetching data for \(dataType): \(error.localizedDescription)") // Debug print statement
                    fetchError = error
                } else if let data = data {
                    aggregatedData += "\(dataType):\n\(data)\n\n"
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = fetchError {
                completion(nil, error)
            } else {
                completion(aggregatedData, nil)
            }
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
