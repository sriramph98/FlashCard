import SwiftUI

struct StudyView: View {
    let deck: Deck
    @Environment(\.dismiss) private var dismiss
    @State private var currentCardIndex = 0
    @State private var isShowingAnswer = false
    
    private var currentCard: Card {
        let index = currentCardIndex % max(1, deck.cards.count)
        return deck.cards.isEmpty ? 
            Card(questionText: "No cards in deck", answerText: "Add some cards to start studying") :
            deck.cards[index]
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    // Image Container
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(radius: 10)
                        
                        if isShowingAnswer {
                            if let image = currentCard.answerImage {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            }
                        } else {
                            if let image = currentCard.questionImage {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            }
                        }
                    }
                    .frame(height: geometry.size.height * 0.4)
                    
                    // Text Container
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(radius: 10)
                        
                        VStack {
                            Text(isShowingAnswer ? "Answer" : "Question")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top)
                            
                            Text(isShowingAnswer ? currentCard.answerText : currentCard.questionText)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    .frame(height: geometry.size.height * 0.2)
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingAnswer.toggle()
                        UIImpactFeedbackGenerator.trigger(.light)
                    }
                }
                
                Spacer()
                
                // Navigation buttons
                if !deck.cards.isEmpty {
                    HStack(spacing: 50) {
                        Button(action: previousCard) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: nextCard) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    if !deck.cards.isEmpty {
                        Text("\(currentCardIndex % deck.cards.count + 1) of \(deck.cards.count)")
                            .font(.subheadline)
                    }
                }
            }
        }
    }
    
    private func nextCard() {
        withAnimation {
            currentCardIndex = (currentCardIndex + 1) % max(1, deck.cards.count)
            isShowingAnswer = false
        }
    }
    
    private func previousCard() {
        withAnimation {
            currentCardIndex = (currentCardIndex - 1 + max(1, deck.cards.count)) % max(1, deck.cards.count)
            isShowingAnswer = false
        }
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