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
    let bulletPoints: [String]
    
    static func == (lhs: Trainer, rhs: Trainer) -> Bool {
        return lhs.imageUrl == rhs.imageUrl && lhs.name == rhs.name
    }
}

class GlobalState: ObservableObject {
    static let shared = GlobalState()
    
    static let trainers = [
        Trainer(imageUrl: "trainer1", name: "Michael", title: "Expert in Running", description: "I’m here to help you enhance your running performance and achieve your goals.", color: .pink, systemMessage: "You are a running expert.", welcomeMessage: "Hi, I'm Michael! I'm an expert in Running. Ready to improve your running performance?", bulletPoints: ["1st place in the Boston Marathon", "Published running researcher", "Loves cats"]),
        Trainer(imageUrl: "trainer2", name: "Joshua", title: "Strength Training Specialist", description: "Let's work together to get you stronger and healthier.", color: .blue, systemMessage: "You are a strength training expert.", welcomeMessage: "Hello, I'm Joshua! I specialize in Strength Training. Let's get stronger today!", bulletPoints: ["Certified Strength and Conditioning Specialist", "Former competitive powerlifter", "Enjoys cooking"]),
        Trainer(imageUrl: "trainer3", name: "Catherine", title: "Cardio Specialist", description: "I'm excited to guide you through heart-pumping workouts that will boost your stamina and energy levels.", color: .green, systemMessage: "You are a cardio specialist.", welcomeMessage: "Hi there, I'm Catherine! I'm a Cardio Specialist. Time for some cardio!", bulletPoints: ["Completed 5 Ironman triathlons", "Masters degree in Exercise Physiology", "Loves to dance"]),
        Trainer(imageUrl: "trainer4", name: "Daniel", title: "Sleep Pro", description: "Let's work on improving your sleep quality so you can wake up feeling refreshed and ready to tackle the day.", color: .orange, systemMessage: "You are a sleep expert.", welcomeMessage: "Hey, I'm Daniel! I'm a Sleep Pro. Ready to improve your sleep quality?", bulletPoints: ["Ph.D. in Sleep Science", "Published author on sleep health", "Enjoys gardening"])
    ]
    
    @Published var systemRole: String = "You are a helpful assistant."
    @Published var trainers: [Trainer] = GlobalState.trainers
    @Published var activeTrainer: Trainer = GlobalState.trainers[0]
}
