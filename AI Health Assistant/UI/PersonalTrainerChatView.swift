import SwiftUI

struct PersonalTrainerChatView: View {
    let characterImage: Image
    let characterName: String
    let characterTagline: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Character Image with overlay
            ZStack(alignment: .bottom) {
                characterImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .clipped()
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]), startPoint: .bottom, endPoint: .top)
                    )
                    .edgesIgnoringSafeArea(.top)
                
                VStack {
                    Text(characterName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    Text(characterTagline)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                }
                .padding()
            }
            
            // Chat View
            ChatBotView()
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding([.horizontal, .top], 20)
                .padding(.bottom, 20)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
}
