import SwiftUI

struct InputView: View {
    @Binding var messageText: String
    @FocusState.Binding var isTextFieldFocused: Bool
    let sendMessage: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            TextField("Type a message", text: $messageText)
                .font(.custom("JosefinSans-VariableFont_wght", size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .focused($isTextFieldFocused)
                .onAppear {
                    DispatchQueue.main.async {
                        isTextFieldFocused = true
                    }
                }
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(messageText.isEmpty ? Color.gray.opacity(0.5) : Color.green)
            }
            .disabled(messageText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.30), radius: 2, x: 0, y: 1)
    }
}
