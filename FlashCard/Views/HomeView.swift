import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = DeckViewModel()
    @State private var showingNewDeckSheet = false
    @State private var showingSettings = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.decks) { deck in
                    NavigationLink(destination: DeckDetailView(deck: deck)) {
                        DeckRowView(deck: deck)
                    }
                }
                .onMove { from, to in
                    viewModel.decks.move(fromOffsets: from, toOffset: to)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteDeck(viewModel.decks[index])
                    }
                }
            }
            .navigationTitle("Decks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .overlay(alignment: .bottom) {
                Button(action: { showingNewDeckSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showingNewDeckSheet) {
            NewDeckView { name in
                viewModel.createDeck(name: name)
                showingNewDeckSheet = false
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct DeckRowView: View {
    let deck: Deck
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(deck.name)
                .font(.headline)
            
            Text("\(deck.cards.count) cards")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct NewDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var deckName = ""
    let onCreate: (String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Deck Name", text: $deckName)
            }
            .navigationTitle("New Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        guard !deckName.isEmpty else { return }
                        onCreate(deckName)
                    }
                    .disabled(deckName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    HomeView()
} 