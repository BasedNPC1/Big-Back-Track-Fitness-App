import SwiftUI

struct ChatView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    @State private var isExpanded = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header/toggle
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundColor(.white)
                    
                    Text(isExpanded ? "Close Assistant" : "Ask AI Assistant")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .foregroundColor(.white)
                        .font(.caption)
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(Color(red: 0.2, green: 0.8, blue: 0.4)) // Green
                .cornerRadius(isExpanded ? 12 : 20)
            }
            
            // Chat content
            if isExpanded {
                // Messages area
                ScrollViewReader { scrollView in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatViewModel.messages) { message in
                                MessageBubble(message: message)
                            }
                        }
                        .padding()
                    }
                    .background(Color(white: 0.1))
                    .onChange(of: chatViewModel.messages.count) { _ in
                        if let lastMessage = chatViewModel.messages.last {
                            withAnimation {
                                scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .frame(height: 250)
                
                // Input area
                HStack(spacing: 8) {
                    TextField("Ask a nutrition question...", text: $chatViewModel.inputMessage)
                        .padding(10)
                        .background(Color(white: 0.15))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                        .focused($isInputFocused)
                    
                    Button(action: {
                        chatViewModel.sendMessage()
                        isInputFocused = false
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4)) // Green
                    }
                    .disabled(chatViewModel.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatViewModel.isLoading)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(white: 0.1))
            }
        }
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 2) {
                Text(message.content)
                    .padding(10)
                    .background(message.isFromUser ? 
                                Color(red: 0.2, green: 0.8, blue: 0.4) : // Green for user
                                Color(white: 0.2)) // Dark gray for AI
                    .foregroundColor(.white)
                    .cornerRadius(12)
                
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !message.isFromUser {
                Spacer()
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ChatView(chatViewModel: ChatViewModel())
                .padding()
        }
    }
}
