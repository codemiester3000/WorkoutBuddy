import SwiftUI

struct ChatBotView: View {
    @ObservedObject private var globalState = GlobalState.shared
    private let queryHandler = QueryHandler()
    
    @State private var messageText = ""
    @State private var conversation: [Message] = []
    @State private var isLoadingResponse = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    private var initialMessage: String {
        globalState.activeTrainer.welcomeMessage
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack() {
                ChatView(conversation: $conversation, isLoadingResponse: $isLoadingResponse)
                
                Spacer()
                
                InputView(messageText: $messageText, isTextFieldFocused: $isTextFieldFocused, sendMessage: sendMessage)
            }
        }
        .onAppear(perform: sendIntroductionResponse)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func sendIntroductionResponse() {
        let initialMessageObject = Message(content: initialMessage, isUserMessage: false)
        conversation.append(initialMessageObject)
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        isLoadingResponse = true
        
        let query = messageText
        let userMessage = Message(content: query, isUserMessage: true)
        conversation.append(userMessage)
        
        queryHandler.handleUserQuery(query) { response, error in
            DispatchQueue.main.async {
                isLoadingResponse = false
                
                if let error = error {
                    print("Error sending message: \(error)")
                    return
                }
                
                if let response = response {
                    let chatGPTMessage = Message(content: response, isUserMessage: false)
                    conversation.append(chatGPTMessage)
                    messageText = ""
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
