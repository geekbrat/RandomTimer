#if os(iOS) || os(macOS)
import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SettingsModel()
    @State private var isPreviewing = false

    var body: some View {
        Form {
            Section("Alarm Sound") {
                Picker("Sound", selection: $settings.alarmSoundRaw) {
                    ForEach(AlarmSound.allCases) { sound in
                        Text(sound.displayName).tag(sound.rawValue)
                    }
                }

                Button {
                    isPreviewing.toggle()
                    if isPreviewing {
                        AlarmService.shared.startSoundPreview()
                    } else {
                        AlarmService.shared.stopSoundPreview()
                    }
                } label: {
                    Label(isPreviewing ? "Stop Preview" : "Preview Sound", systemImage: isPreviewing ? "stop.fill" : "play.fill")
                }
            }

            Section {
                Text("© 2026 Kirstyn Piper Plummer")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .onDisappear {
            AlarmService.shared.stopSoundPreview()
        }
    }
}
#endif
