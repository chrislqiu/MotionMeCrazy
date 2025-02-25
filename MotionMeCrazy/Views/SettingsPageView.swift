import SwiftUI

struct SettingsPageView: View {
    @State private var audioLevel: Double = 0.5
    @State private var showLanguageAlert = false
    
    let languages = [
        ("English", "en"),
        ("Español", "es")
    ]

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack {
                settingsContent
            }
            .padding()
            .environment(\.locale, Locale(identifier: LanguageManager.shared.selectedLanguage))
        }
    }

    var settingsContent: some View {
        VStack(spacing: 20) {
            CustomHeader(config: .init(title: NSLocalizedString("Settings", comment: "")))

            // Audio Settings
            VStack(alignment: .leading) {
                CustomText(config: .init(text: NSLocalizedString("Audio Level", comment: "")))
                Slider(value: $audioLevel, in: 0...1)
                    .accentColor(.darkBlue)
            }
            .padding()

            CustomButton(config: .init(title: NSLocalizedString("Change Theme", comment: ""), width: 200, buttonColor: .darkBlue) {})

            // using alert
            CustomButton(config: .init(title: NSLocalizedString("Change Language", comment: ""), width: 200, buttonColor: .darkBlue) {
                showLanguageAlert.toggle()
            })
        }
        .alert("Select Language", isPresented: $showLanguageAlert) {
            ForEach(languages, id: \.1) { language in
                Button(language.0) {
                    LanguageManager.shared.selectedLanguage = language.1 //change language
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    SettingsPageView()
}
