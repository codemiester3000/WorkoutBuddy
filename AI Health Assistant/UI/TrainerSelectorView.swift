import SwiftUI

struct HomePageView: View {
    @ObservedObject var globalState = GlobalState.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("Choose Your Trainer")
                            .font(.custom("JosefinSans-VariableFont_wght", size: 24))
                            .bold()
                            .padding(.vertical)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(globalState.trainers, id: \.imageUrl) { trainer in
                            NavigationLink(
                                destination: PersonalTrainerChatView(
                                    characterImage: Image(trainer.imageUrl),
                                    characterName: trainer.name,
                                    characterTagline: trainer.title
                                ),
                                label: {
                                    TrainerCard(trainer: trainer)
                                        .frame(height: 250)
                                }
                            )
                            .simultaneousGesture(TapGesture().onEnded {
                                print("\n updating the current trainer: ", trainer.name)
                                globalState.activeTrainer = trainer
                            })
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }
}


struct TrainerCard: View {
    var trainer: Trainer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(trainer.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadiusSpecific(15, corners: [.topLeft, .topRight])
            
            VStack(alignment: .leading, spacing: 5) {
                Text(trainer.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(trainer.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [trainer.color.opacity(0.3), trainer.color.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadiusSpecific(15, corners: [.bottomLeft, .bottomRight])
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 2)
    }
}

extension View {
    func cornerRadiusSpecific(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(SpecificRoundedCorner(radius: radius, corners: corners))
    }
}

struct SpecificRoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
