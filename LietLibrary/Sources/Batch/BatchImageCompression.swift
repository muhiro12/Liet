import Foundation

public enum BatchImageCompression: String, CaseIterable, Codable, Sendable {
    case high
    case medium
    case low
}

public extension BatchImageCompression {
    var quality: Double {
        switch self {
        case .high:
            0.9
        case .medium:
            0.7
        case .low:
            0.5
        }
    }
}
