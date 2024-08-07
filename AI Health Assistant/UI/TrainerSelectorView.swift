import SwiftUI

struct TrainerSelectorView: View {
    @ObservedObject var globalState = GlobalState.shared

    @State private var selectedTrainer: Trainer?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    headerView

                    ForEach(globalState.trainers, id: \.imageUrl) { trainer in
                        TrainerRow(trainer: trainer, isExpanded: selectedTrainer?.name == trainer.name)
                            .onTapGesture {
                                withAnimation {
                                    if selectedTrainer?.name == trainer.name {
                                        selectedTrainer = nil
                                    } else {
                                        selectedTrainer = trainer
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }

    var headerView: some View {
        Text("Choose Your Trainer")
            .font(.custom("JosefinSans-VariableFont_wght", size: 24))
            .bold()
            .padding(.vertical, 10)
            .padding(.horizontal)
    }
}

struct TrainerRow: View {
    var trainer: Trainer
    var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading) {
            rowHeader

            if isExpanded {
                expandedView
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.vertical, 5)
    }

    var rowHeader: some View {
        HStack {
            Image(trainer.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(10)

            VStack(alignment: .leading) {
                Text(trainer.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(trainer.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
    }

    var expandedView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(trainer.description)
                .font(.subheadline)
                .foregroundColor(.primary)

            NavigationLink(destination: PersonalTrainerChatView(
                characterImage: Image(trainer.imageUrl),
                characterName: trainer.name,
                characterTagline: trainer.title
            )) {
                Text("Begin Discussion")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
