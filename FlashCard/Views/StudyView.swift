import SwiftUI

struct StudyView: View {
    let deck: Deck
    @Environment(\.dismiss) private var dismiss
    @State private var currentCardIndex = 0
    @State private var isShowingAnswer = false
    @State private var rotation: Double = 0
    
    private var currentCard: Card {
        let index = currentCardIndex % max(1, deck.cards.count)
        return deck.cards.isEmpty ? 
            Card(questionText: "No cards in deck", answerText: "Add some cards to start studying") :
            deck.cards[index]
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                // Card Container
                ZStack {
                    // Question Side
                    CardFace(
                        text: currentCard.questionText,
                        label: "Question",
                        isVisible: !isShowingAnswer,
                        image: currentCard.questionImage
                    )
                    
                    // Answer Side
                    CardFace(
                        text: currentCard.answerText,
                        label: "Answer",
                        isVisible: isShowingAnswer,
                        image: currentCard.answerImage
                    )
                    .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
                }
                .frame(height: min(geometry.size.height * 0.6, 400))
                .padding()
                .contentShape(Rectangle())
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (0, 1, 0)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        rotation += 180
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isShowingAnswer.toggle()
                        }
                        UIImpactFeedbackGenerator.trigger(.light)
                    }
                }
                
                Spacer()
                
                // Card Count and Navigation
                VStack(spacing: 16) {
                    if !deck.cards.isEmpty {
                        Text("\(currentCardIndex % deck.cards.count + 1) of \(deck.cards.count)")
                            .font(.subheadline)
                    }
                    
                    if !deck.cards.isEmpty {
                        HStack(spacing: 20) {
                            NavigationButton(
                                action: previousCard,
                                systemName: "arrow.backward",
                                isEnabled: currentCardIndex > 0
                            )
                            
                            NavigationButton(
                                action: nextCard,
                                systemName: "arrow.forward",
                                isEnabled: currentCardIndex < deck.cards.count - 1
                            )
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(deck.name)
                        .font(.headline)
                }
            }
        }
    }
    
    private func nextCard() {
        withAnimation {
            currentCardIndex = min(currentCardIndex + 1, deck.cards.count - 1)
            isShowingAnswer = false
            rotation = 0
        }
    }
    
    private func previousCard() {
        withAnimation {
            currentCardIndex = max(currentCardIndex - 1, 0)
            isShowingAnswer = false
            rotation = 0
        }
    }
}

// MARK: - Supporting Views
private struct CardFace: View {
    let text: String
    let label: String
    let isVisible: Bool
    let image: Image? // Changed to SwiftUI Image type
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            
            VStack(spacing: 16) {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Text(text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .opacity(isVisible ? 1 : 0)
    }
    
    // Convenience initializer with optional image
    init(text: String, label: String, isVisible: Bool, image: Image? = nil) {
        self.text = text
        self.label = label
        self.isVisible = isVisible
        self.image = image
    }
}

private struct NavigationButton: View {
    let action: () -> Void
    let systemName: String
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(isEnabled ? 1.0 : 0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    NavigationStack {
        StudyView(deck: Deck(name: "Sample Deck", cards: [
            Card(questionText: "What is the capital of France?", answerText: "Paris"),
            Card(questionText: "What is 2 + 2?", answerText: "4")
        ]))
    }
} 