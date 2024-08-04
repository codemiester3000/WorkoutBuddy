import Foundation

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUserMessage: Bool
}
