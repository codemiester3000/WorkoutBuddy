import Combine
import Foundation

class ActiveAgentsManager: ObservableObject {
    static let shared = ActiveAgentsManager()
    @Published var activeDataTypes: [String] = []

    private init() {}

    func setActiveDataTypes(_ types: [String]) {
        DispatchQueue.main.async {
            self.activeDataTypes = types
        }
    }

    func clearActiveDataTypes() {
        DispatchQueue.main.async {
            self.activeDataTypes = []
        }
    }
}


