import SwiftUI
import PhotosUI

struct CardEditView: View {
    @Environment(\.dismiss) private var dismiss
    let card: Card?
    let onSave: (Card) -> Void
    
    @State private var questionText: String
    @State private var answerText: String
    @State private var questionImageData: Data?
    @State private var answerImageData: Data?
    @State private var questionImageSelection: PhotosPickerItem?
    @State private var answerImageSelection: PhotosPickerItem?
    @State private var showingPhotoError = false
    @State private var photoErrorMessage = ""
    
    init(card: Card?, onSave: @escaping (Card) -> Void) {
        self.card = card
        self.onSave = onSave
        _questionText = State(initialValue: card?.questionText ?? "")
        _answerText = State(initialValue: card?.answerText ?? "")
        _questionImageData = State(initialValue: card?.questionImageData)
        _answerImageData = State(initialValue: card?.answerImageData)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Question", text: $questionText, axis: .vertical)
                            .textInputAutocapitalization(.never)
                            .lineLimit(3...6)
                        
                        HStack {
                            PhotosPicker(selection: $questionImageSelection,
                                       matching: .images,
                                       photoLibrary: .shared()) {
                                if let questionImageData,
                                   let uiImage = UIImage(data: questionImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Label("Add Image", systemImage: "photo")
                                        .frame(width: 80, height: 80)
                                        .background(Color.secondary.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            
                            if questionImageData != nil {
                                Button(role: .destructive) {
                                    questionImageData = nil
                                    questionImageSelection = nil
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                                .buttonStyle(.borderless)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                Section("Answer") {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Answer", text: $answerText, axis: .vertical)
                            .textInputAutocapitalization(.never)
                            .lineLimit(3...6)
                        
                        HStack {
                            PhotosPicker(selection: $answerImageSelection,
                                       matching: .images,
                                       photoLibrary: .shared()) {
                                if let answerImageData,
                                   let uiImage = UIImage(data: answerImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Label("Add Image", systemImage: "photo")
                                        .frame(width: 80, height: 80)
                                        .background(Color.secondary.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            
                            if answerImageData != nil {
                                Button(role: .destructive) {
                                    answerImageData = nil
                                    answerImageSelection = nil
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                                .buttonStyle(.borderless)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(card == nil ? "New Card" : "Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newCard = Card(
                            id: card?.id ?? UUID(),
                            questionText: questionText,
                            questionImageData: questionImageData,
                            answerText: answerText,
                            answerImageData: answerImageData
                        )
                        onSave(newCard)
                        dismiss()
                    }
                    .disabled(questionText.isEmpty || answerText.isEmpty)
                }
            }
            .onChange(of: questionImageSelection) { _, newValue in
                Task {
                    do {
                        if let data = try await newValue?.loadTransferable(type: Data.self) {
                            // Compress image if needed
                            if let image = UIImage(data: data), data.count > 1_000_000 {
                                questionImageData = image.jpegData(compressionQuality: 0.5)
                            } else {
                                questionImageData = data
                            }
                        }
                    } catch {
                        showingPhotoError = true
                        photoErrorMessage = error.localizedDescription
                    }
                }
            }
            .onChange(of: answerImageSelection) { _, newValue in
                Task {
                    do {
                        if let data = try await newValue?.loadTransferable(type: Data.self) {
                            // Compress image if needed
                            if let image = UIImage(data: data), data.count > 1_000_000 {
                                answerImageData = image.jpegData(compressionQuality: 0.5)
                            } else {
                                answerImageData = data
                            }
                        }
                    } catch {
                        showingPhotoError = true
                        photoErrorMessage = error.localizedDescription
                    }
                }
            }
            .alert("Photo Error", isPresented: $showingPhotoError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(photoErrorMessage)
            }
        }
    }
}

#Preview {
    CardEditView(card: nil) { _ in }
} 