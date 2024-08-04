import SwiftUI

struct HeartRateAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            Text("Pulling Heart Rate Data")
                .font(.custom("JosefinSans-VariableFont_wght", size: 12, relativeTo: .body))
                .foregroundColor(.primary.opacity(0.5))
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
        }
    }
}
