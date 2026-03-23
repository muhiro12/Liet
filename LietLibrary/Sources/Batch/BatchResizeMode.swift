import Foundation

public enum BatchResizeMode: Equatable, Codable, Sendable {
    case longEdgePixels(Int)

    public static let defaultLongEdgePixels = 1920
    public static let `default`: Self = .longEdgePixels(defaultLongEdgePixels)
}

public extension BatchResizeMode {
    init(longEdgePixels: Int = Self.defaultLongEdgePixels) {
        self = .longEdgePixels(longEdgePixels)
    }

    var longEdgePixels: Int {
        switch self {
        case let .longEdgePixels(pixels):
            max(1, pixels)
        }
    }
}
