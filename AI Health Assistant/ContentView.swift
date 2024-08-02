import SwiftUI

struct ContentView: View {
    private let queryHandler = QueryHandler()
    private let initialMessage = """
        Hello! I am your Health Assistant powered by HealthKit and GPT. I can analyze your HealthKit data to provide insights on your health and fitness. Ask me anything about your health data, workouts, or general health advice. How can I help you today?
        """
    
    @State private var messageText = ""
    @State private var conversation: [Message] = []
    @State private var isTyping = false
    @State private var isInitialQuerySent = false
    @State private var isOverviewQuerySent = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                headerView
                
                chatView
                
                inputView
            }
        }
        .onAppear(perform: initializeHealthKit)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("HealthGPT")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .font(.system(size: 24))
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private var chatView: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(conversation) { message in
                        MessageView(message: message)
                    }
                    
                    if isTyping {
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
    
    private var inputView: some View {
        HStack(spacing: 12) {
            TextField("Type a message", text: $messageText)
                .textFieldStyle(ModernTextFieldStyle())
                .focused($isTextFieldFocused)
            
            Button(action: {
                sendMessage()
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(messageText.isEmpty ? .gray : .blue)
            }
            .disabled(messageText.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private func initializeHealthKit() {
        if !isInitialQuerySent {
            let initialMessageObject = Message(content: initialMessage, isUserMessage: false)
            conversation.append(initialMessageObject)
            isInitialQuerySent = true
        }
    }
    
    private func scrollToBottom(scrollProxy: ScrollViewProxy) {
        guard let lastMessage = conversation.last else { return }
        scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
    }
    
    private func sendMessage(initialQuery: String? = nil) {
        isTyping = true
        
        let query = initialQuery ?? messageText
        let userMessage = Message(content: query, isUserMessage: true)
        
        conversation.append(userMessage)
        
        print("making call to handle user query")
        queryHandler.handleUserQuery(query) { response, error in
            isTyping = false
            
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUserMessage {
                Spacer()
                Text(message.content)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(18)
                    .cornerRadius(4, corners: [.topRight])
            } else {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 32))
                
                Text(message.content)
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(18)
                    .cornerRadius(4, corners: [.topLeft])
            }
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUserMessage: Bool
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct TypingIndicatorView: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

