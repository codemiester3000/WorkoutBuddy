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
                            .simultaneousGesture(
                                TapGesture().onEnded {
                                    print("\nUpdating the current trainer: ", trainer.name)
                                    globalState.activeTrainer = trainer
                                }
                            )
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
        HStack(alignment: .top, spacing: 16) {
            Image(trainer.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(15)
                .shadow(radius: 3)

            VStack(alignment: .leading, spacing: 8) {
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(trainer.description)
                    .font(.custom("JosefinSans-VariableFont_wght", size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: {
                    // Action to request HealthKit access
                }) {
                    Text("Grant HealthKit Access")
                        .font(.custom("JosefinSans-VariableFont_wght", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 5)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(trainer.bulletPoints, id: \.self) { point in
                    HStack(alignment: .top) {
                        Text("•")
                            .font(.custom("JosefinSans-VariableFont_wght", size: 16))
                            .foregroundColor(.primary)
                        Text(point)
                            .font(.custom("JosefinSans-VariableFont_wght", size: 16))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            NavigationLink(destination: PersonalTrainerChatView(
//                characterImage: Image(trainer.imageUrl),
//                characterName: trainer.name,
//                characterTagline: trainer.title
            )) {
                Text("Begin Discussion")
                    .font(.custom("JosefinSans-VariableFont_wght", size: 16))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 5)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
