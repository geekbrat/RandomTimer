import Foundation

enum AlarmSound: String, CaseIterable, Identifiable {
    case soft = "alarm_soft"
    case classic = "alarm_classic"
    case urgent = "alarm_urgent"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .soft: return "Soft Chime"
        case .classic: return "Classic Beep"
        case .urgent: return "Urgent Siren"
        }
    }

    var filename: String { rawValue }
    var fileExtension: String { "wav" }
}
