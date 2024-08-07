import SwiftUI
import Combine
import UIKit

struct Trainer {
    let imageUrl: String
    let name: String
    let title: String
    let description: String
    let color: Color
    let systemMessage: String
    let welcomeMessage: String
    
    static func == (lhs: Trainer, rhs: Trainer) -> Bool {
        return lhs.imageUrl == rhs.imageUrl && lhs.name == rhs.name
    }
}

class GlobalState: ObservableObject {
    static let shared = GlobalState()
    
    static let trainers = [
        Trainer(imageUrl: "trainer1", name: "Michael", title: "Expert in Yoga", description: "You are a yoga expert.", color: .pink, systemMessage: "You are a yoga expert.", welcomeMessage: "Hi, I'm Michael! I'm an expert in Yoga. Ready for your Yoga session?"),
        Trainer(imageUrl: "trainer2", name: "Joshua", title: "Strength Training", description: "You are a strength training expert.", color: .blue, systemMessage: "You are a strength training expert.", welcomeMessage: "Hello, I'm Joshua! I specialize in Strength Training. Let's get stronger today!"),
        Trainer(imageUrl: "trainer3", name: "Catherine", title: "Cardio Specialist", description: "You are a cardio specialist.", color: .green, systemMessage: "You are a cardio specialist.", welcomeMessage: "Hi there, I'm Catherine! I'm a Cardio Specialist. Time for some cardio!"),
        Trainer(imageUrl: "trainer4", name: "Daniel", title: "Pilates Pro", description: "You are a pilates pro.", color: .orange, systemMessage: "You are a pilates pro.", welcomeMessage: "Hey, I'm Daniel! I'm a Pilates Pro. Ready for Pilates?")
    ]
    
    @Published var systemRole: String = "You are a helpful assistant."
    @Published var trainers: [Trainer] = GlobalState.trainers
    @Published var activeTrainer: Trainer = GlobalState.trainers[0]
}
