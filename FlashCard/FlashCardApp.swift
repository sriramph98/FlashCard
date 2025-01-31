//
//  FlashCardApp.swift
//  FlashCard
//
//  Created by Sriram P H on 1/30/25.
//

import SwiftUI

@main
struct FlashCardApp: App {
    @StateObject private var deckViewModel = DeckViewModel()
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(deckViewModel)
                .preferredColorScheme(colorScheme)
                .frame(minWidth: 400, minHeight: 300)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
    
    private var colorScheme: ColorScheme? {
        if useSystemTheme {
            return nil
        }
        return isDarkMode ? .dark : .light
    }
}

// MARK: - Haptics
extension UIImpactFeedbackGenerator {
    static func trigger(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        if UserDefaults.standard.bool(forKey: "enableHaptics") {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}
