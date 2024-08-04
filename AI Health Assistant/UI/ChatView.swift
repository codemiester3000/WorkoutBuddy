import SwiftUI

struct ChatView: View {
    @Binding var conversation: [Message]
    @Binding var isLoadingResponse: Bool
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(conversation) { message in
                        if message.isUserMessage {
                            UserMessageView(message: message)
                        } else {
                            AIResponseView(message: message)
                        }
                    }
                    
                    if isLoadingResponse {
                        TypingIndicatorView()
                            .padding(.vertical)
                            .id("typingIndicator")
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .onChange(of: conversation.count) { _ in
                    withAnimation {
                        scrollToBottom(scrollProxy: scrollProxy)
                    }
                }
            }
        }
    }
    
    private func scrollToBottom(scrollProxy: ScrollViewProxy) {
        guard let lastMessage = conversation.last else { return }
        scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
    }
}
