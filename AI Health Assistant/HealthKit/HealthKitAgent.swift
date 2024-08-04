import Foundation

protocol HealthKitAgent {
    func fetchData(from startDate: Date, to endDate: Date, completion: @escaping (String?, Error?) -> Void)
    func agentName() -> String
}
