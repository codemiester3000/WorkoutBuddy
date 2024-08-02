import Foundation

protocol HealthKitFetcher {
    func fetchData(from startDate: Date, to endDate: Date, completion: @escaping (String?, Error?) -> Void)
}
