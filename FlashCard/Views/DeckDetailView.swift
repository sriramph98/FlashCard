import SwiftUI
import PhotosUI

struct DeckDetailView: View {
    @EnvironmentObject private var viewModel: DeckViewModel
    let deck: Deck
    
    @State private var showingNewCardSheet = false
    @State private var editingCard: Card?
    
    var cardCountText: String {
        let count = deck.cards.count
        return "\(count) " + (count == 1 ? "card" : "cards")
    }
    
    var body: some View {
        List {
            ForEach(deck.cards) { card in
                CardRowView(card: card)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingCard = card
                    }
            }
            .onMove { from, to in
                if let deckIndex = viewModel.decks.firstIndex(where: { $0.id == deck.id }) {
                    viewModel.decks[deckIndex].cards.move(fromOffsets: from, toOffset: to)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    viewModel.deleteCard(deck.cards[index], from: deck)
                }
            }
        }
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(deck.name)
                        .font(.headline)
                    Text(cardCountText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: StudyView(deck: deck)) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 22))
                }
                .disabled(deck.cards.isEmpty)
            }
        }
        .overlay(alignment: .bottom) {
            Button(action: { showingNewCardSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.bottom)
        }
        .sheet(isPresented: $showingNewCardSheet) {
            CardEditView(card: nil) { card in
                viewModel.addCard(to: deck, card: card)
                showingNewCardSheet = false
            }
        }
        .sheet(item: $editingCard) { card in
            CardEditView(card: card) { updatedCard in
                if let index = deck.cards.firstIndex(where: { $0.id == card.id }) {
                    viewModel.decks[viewModel.decks.firstIndex(where: { $0.id == deck.id })!].cards[index] = updatedCard
                }
            }
        }
    }
}

struct CardRowView: View {
    let card: Card
    
    var body: some View {
        HStack(spacing: 12) {
            if let image = card.questionImage {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Text(card.questionText)
                .font(.headline)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        DeckDetailView(deck: Deck(name: "Sample Deck"))
            .environmentObject(DeckViewModel())
    }
} 