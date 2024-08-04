import SwiftUI
import Combine

struct DynamicGradientView: View {
    @State private var gradient = Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)])
    @State private var startPoint = UnitPoint.topLeading
    @State private var endPoint = UnitPoint.bottomTrailing

    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect() // Slower transition time

    var body: some View {
        LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
            .animation(Animation.easeInOut(duration: 10).repeatForever(autoreverses: false), value: gradient)
            .onReceive(timer, perform: { _ in
                // Subtle change in gradient colors
                gradient = Gradient(colors: [
                    Color(red: .random(in: 0.7...1), green: .random(in: 0.7...1), blue: .random(in: 0.7...1)).opacity(0.2),
                    Color(red: .random(in: 0.7...1), green: .random(in: 0.7...1), blue: .random(in: 0.7...1)).opacity(0.2)
                ])
                // Less dramatic change in the flow of the gradient
                startPoint = UnitPoint(x: .random(in: 0.4...0.6), y: .random(in: 0.4...0.6))
                endPoint = UnitPoint(x: .random(in: 0.4...0.6), y: .random(in: 0.4...0.6))
            })
            .edgesIgnoringSafeArea(.all)
    }
}

struct HomePageView: View {
    let trainers = [
        ("trainer1", "Expert in Yoga"),
        ("trainer2", "Strength Training"),
        ("trainer3", "Cardio Specialist"),
        ("trainer4", "Pilates Pro")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Welcome to Your Fitness App")
                        .font(.largeTitle)
                        .padding(.top, 40)
                    
                    Text("Choose Your Trainer")
                        .font(.title2)
                        .padding(.bottom, 20)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(trainers, id: \.0) { trainer in
                            TrainerCard(trainer: trainer)
                                .frame(height: 250)
                                .shadow(radius: 10)
                            
                                .buttonStyle(PlainButtonStyle()) // To remove any default styling
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle(Text("Home"), displayMode: .automatic)
            .background(DynamicGradientView())  // Apply the dynamic background here
        }
    }
}

struct TrainerCard: View {
    var trainer: (String, String)
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(trainer.0) // Assuming the image name matches the trainer identifier
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(15, corners: [.topLeft, .topRight])
            
            VStack(alignment: .leading, spacing: 5) {
                Text(trainer.0.replaceUnderscores())
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(trainer.1)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
        }
        .background(Color.white)
        .cornerrRadius(15, corners: .allCorners)
        .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 2)
    }
}

extension View {
    func cornerrRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundeddCorner(radius: radius, corners: corners))
    }
}

struct RoundeddCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let bezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            path.addPath(Path(bezierPath.cgPath))
        }
    }
}

extension String {
    func replaceUnderscores() -> String {
        self.replacingOccurrences(of: "_", with: " ")
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
