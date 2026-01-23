import SwiftUI
import Combine

enum SettingsKeys {
    static let alarmSound = "settings.alarmSound"
}

@MainActor
final class SettingsModel: ObservableObject {
    @AppStorage(SettingsKeys.alarmSound) var alarmSoundRaw: String = AlarmSound.classic.rawValue

    var alarmSound: AlarmSound {
        get { AlarmSound(rawValue: alarmSoundRaw) ?? .classic }
        set { alarmSoundRaw = newValue.rawValue }
    }
}
