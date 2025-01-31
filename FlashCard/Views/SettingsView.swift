import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("enableAutoSync") private var enableAutoSync = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Toggle("Use System Theme", isOn: $useSystemTheme)
                    
                    if !useSystemTheme {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                    }
                }
                
                Section("Behavior") {
                    Toggle("Enable Haptics", isOn: $enableHaptics)
                    Toggle("Auto-sync with iCloud", isOn: $enableAutoSync)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy",
                         destination: URL(string: "https://www.example.com/privacy")!)
                    
                    Link("Terms of Service",
                         destination: URL(string: "https://www.example.com/terms")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
} 