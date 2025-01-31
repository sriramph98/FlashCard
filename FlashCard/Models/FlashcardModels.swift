import Foundation
import SwiftUI
import CloudKit

struct Deck: Identifiable, Codable {
    var id: UUID
    var name: String
    var cards: [Card]
    var createdAt: Date
    var modifiedAt: Date
    
    init(id: UUID = UUID(), name: String, cards: [Card] = [], createdAt: Date = Date(), modifiedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.cards = cards
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

struct Card: Identifiable, Codable {
    var id: UUID
    var questionText: String
    var questionImageData: Data?
    var answerText: String
    var answerImageData: Data?
    var createdAt: Date
    var modifiedAt: Date
    
    init(id: UUID = UUID(), 
         questionText: String, 
         questionImageData: Data? = nil,
         answerText: String,
         answerImageData: Data? = nil,
         createdAt: Date = Date(),
         modifiedAt: Date = Date()) {
        self.id = id
        self.questionText = questionText
        self.questionImageData = questionImageData
        self.answerText = answerText
        self.answerImageData = answerImageData
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
    
    var questionImage: Image? {
        guard let data = questionImageData,
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    var answerImage: Image? {
        guard let data = answerImageData,
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }
}

// MARK: - CSV Import/Export
extension Card {
    struct CSVRepresentation {
        let questionImage: String // Base64 encoded
        let questionText: String
        let answerImage: String // Base64 encoded
        let answerText: String
    }
    
    func toCSV() -> CSVRepresentation {
        return CSVRepresentation(
            questionImage: questionImageData?.base64EncodedString() ?? "",
            questionText: questionText,
            answerImage: answerImageData?.base64EncodedString() ?? "",
            answerText: answerText
        )
    }
    
    static func fromCSV(_ csv: CSVRepresentation) -> Card? {
        let questionImageData = Data(base64Encoded: csv.questionImage)
        let answerImageData = Data(base64Encoded: csv.answerImage)
        
        return Card(
            questionText: csv.questionText,
            questionImageData: questionImageData,
            answerText: csv.answerText,
            answerImageData: answerImageData
        )
    }
} 