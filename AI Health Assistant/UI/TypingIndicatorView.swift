import SwiftUI

struct TypingIndicatorView: View {
    @ObservedObject private var activeAgentsManager = ActiveAgentsManager.shared
    @State private var animationOffset: CGFloat = 0

    var isQueryingHeartRate: Bool {
        activeAgentsManager.activeDataTypes.contains("HeartRateData")
    }

    var body: some View {
        VStack {
            if isQueryingHeartRate {
                HeartRateAnimationView()
            } else {
                defaultTypingIndicator
            }
        }
    }

    private var defaultTypingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            animationOffset = -5
        }
    }
}


//import SwiftUI
//
//struct TypingIndicatorView: View {
//    @State private var animationOffset: CGFloat = 0
//    @ObservedObject private var activeAgentsManager = ActiveAgentsManager.shared  // Access the singleton
//
//    var body: some View {
//        VStack {
//            HStack(spacing: 4) {
//                ForEach(0..<3) { index in
//                    Circle()
//                        .fill(Color.gray)
//                        .frame(width: 8, height: 8)
//                        .offset(y: animationOffset)
//                        .animation(
//                            Animation.easeInOut(duration: 0.6)
//                                .repeatForever()
//                                .delay(0.2 * Double(index)),
//                            value: animationOffset
//                        )
//                }
//            }
//            .onAppear {
//                animationOffset = -5
//            }
//
//            if !activeAgentsManager.activeDataTypes.isEmpty {
//                Text("Querying: \(activeAgentsManager.activeDataTypes.joined(separator: ", "))")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//        }
//    }
//}
