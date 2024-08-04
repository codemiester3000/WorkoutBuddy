import SwiftUI

struct AIResponseView: View {
    let message: Message
    @State private var displayedText = ""
    @State private var hasStartedTyping = false
    private let typingSpeed: Double = 0.05

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "heart.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 30, weight: .light))
                .symbolRenderingMode(.hierarchical)
            
            Text(displayedText)
                .font(.custom("JosefinSans-VariableFont_wght", size: 16, relativeTo: .body))
                .padding(12)
                .lineSpacing(8)
                .background(Color(UIColor.secondarySystemBackground))
                .foregroundColor(.primary)
                .cornerRadius(18)
                .cornerRadius(4, corners: [.topLeft])
                .onAppear {
                    if !hasStartedTyping {
                        hasStartedTyping = true
                        typeText()
                    }
                }
        }
    }

    private func typeText() {
        let words = message.content.split(separator: " ")
        var currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if currentIndex < words.count {
                displayedText += (currentIndex > 0 ? " " : "") + words[currentIndex]
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}
