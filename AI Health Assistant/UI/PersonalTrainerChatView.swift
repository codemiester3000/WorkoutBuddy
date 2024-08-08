import SwiftUI

struct PersonalTrainerChatView: View {
    @ObservedObject private var globalState = GlobalState.shared
    
    var body: some View {
        VStack(spacing: 0) {
            TrainerInfo(trainer: globalState.activeTrainer)
                .padding(.bottom, 10)
            
            ChatBotView()
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(20)
                .padding(.vertical, 10)
                .padding(.bottom, 16)
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

struct TrainerInfo: View {
    var trainer: Trainer

    var body: some View {
        ZStack(alignment: .leading) {
            Image(trainer.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()

            VStack(alignment: .leading) {
                Text(trainer.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                Text(trainer.title)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.75))
                    .shadow(radius: 5)
            }
            .padding()
        }
        .cornerRadius(20)
        .shadow(color: trainer.color.opacity(0.4), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}
