import SwiftUI
import CloudKit
import Combine

@MainActor
class DeckViewModel: ObservableObject {
    @Published var decks: [Deck] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let container: CKContainer
    private let database: CKDatabase
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize CloudKit container
        container = CKContainer(identifier: "iCloud.com.yourname.FlashCard")
        database = container.privateCloudDatabase
        
        loadLocalDecks()
        setupCloudSync()
        
        // Check iCloud status
        Task {
            await checkAccountStatus()
        }
    }
    
    private func checkAccountStatus() async {
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                print("iCloud is available")
                await fetchCloudChanges()
            case .noAccount:
                error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No iCloud account found. Please sign in to iCloud in Settings."])
            case .restricted:
                error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "iCloud access is restricted."])
            case .couldNotDetermine:
                error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not determine iCloud account status."])
            @unknown default:
                error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown iCloud account status."])
            }
        } catch {
            self.error = error
        }
    }
    
    private func fetchCloudChanges() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let query = CKQuery(recordType: "Deck", predicate: NSPredicate(value: true))
            let result = try await database.records(matching: query)
            // Handle cloud data here
            print("Fetched records from CloudKit")
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Deck Management
    
    func createDeck(name: String) {
        let newDeck = Deck(name: name)
        decks.append(newDeck)
        saveDecks()
    }
    
    func deleteDeck(_ deck: Deck) {
        decks.removeAll { $0.id == deck.id }
        saveDecks()
    }
    
    func addCard(to deck: Deck, card: Card) {
        guard let index = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[index].cards.append(card)
        decks[index].modifiedAt = Date()
        saveDecks()
    }
    
    func deleteCard(_ card: Card, from deck: Deck) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[deckIndex].cards.removeAll { $0.id == card.id }
        decks[deckIndex].modifiedAt = Date()
        saveDecks()
    }
    
    func updateCard(_ updatedCard: Card, in deck: Deck) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }),
              let cardIndex = decks[deckIndex].cards.firstIndex(where: { $0.id == updatedCard.id }) else { return }
        decks[deckIndex].cards[cardIndex] = updatedCard
        decks[deckIndex].modifiedAt = Date()
        saveDecks()
    }
    
    func moveCards(in deck: Deck, from source: IndexSet, to destination: Int) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[deckIndex].cards.move(fromOffsets: source, toOffset: destination)
        decks[deckIndex].modifiedAt = Date()
        saveDecks()
    }
    
    // MARK: - Persistence
    
    private func loadLocalDecks() {
        guard let data = UserDefaults.standard.data(forKey: "flashcards.decks") else { return }
        do {
            decks = try JSONDecoder().decode([Deck].self, from: data)
        } catch {
            self.error = error
        }
    }
    
    private func saveDecks() {
        do {
            let data = try JSONEncoder().encode(decks)
            UserDefaults.standard.set(data, forKey: "flashcards.decks")
            syncToCloud()
        } catch {
            self.error = error
        }
    }
    
    // MARK: - CloudKit Sync
    
    private func setupCloudSync() {
        // Setup iCloud change notifications
        NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
            .sink { [weak self] _ in
                self?.handleCloudChanges()
            }
            .store(in: &cancellables)
            
        // Activate iCloud key-value store
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    private func syncToCloud() {
        Task {
            do {
                let database = container.privateCloudDatabase
                // Implementation of CloudKit sync logic here
                // This is a placeholder for the actual CloudKit implementation
            } catch {
                self.error = error
            }
        }
    }
    
    private func handleCloudChanges() {
        // Handle incoming changes from iCloud
        // This is a placeholder for the actual CloudKit implementation
    }
    
    // MARK: - CSV Import/Export
    
    func importFromCSV(url: URL, to deck: Deck) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        
        do {
            let csvString = try String(contentsOf: url, encoding: .utf8)
            let rows = csvString.components(separatedBy: .newlines)
            
            for row in rows where !row.isEmpty {
                let columns = row.components(separatedBy: ",")
                guard columns.count == 4 else { continue }
                
                let card = Card(
                    questionText: columns[1].trimmingCharacters(in: .whitespacesAndNewlines),
                    questionImageData: Data(base64Encoded: columns[0].trimmingCharacters(in: .whitespacesAndNewlines)),
                    answerText: columns[3].trimmingCharacters(in: .whitespacesAndNewlines),
                    answerImageData: Data(base64Encoded: columns[2].trimmingCharacters(in: .whitespacesAndNewlines))
                )
                
                decks[deckIndex].cards.append(card)
            }
            
            decks[deckIndex].modifiedAt = Date()
            saveDecks()
        } catch {
            self.error = error
        }
    }
    
    func exportToCSV(deck: Deck) -> URL? {
        let csvString = deck.cards.map { card -> String in
            let csv = card.toCSV()
            return "\(csv.questionImage),\(csv.questionText),\(csv.answerImage),\(csv.answerText)"
        }.joined(separator: "\n")
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(deck.name).csv")
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            self.error = error
            return nil
        }
    }
} 