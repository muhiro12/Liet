import Foundation

/// Resizing modes supported by the MVP batch processor.
public enum BatchResizeMode: Equatable, Codable, Sendable {
    /// Scales an image so its longest edge matches the provided pixel value.
    case longEdgePixels(Int)

    /// Default longest-edge target used by the app.
    public static let defaultLongEdgePixels = 1_920
    /// Default resize mode used by the app.
    public static let `default`: Self = .longEdgePixels(defaultLongEdgePixels)
}

public extension BatchResizeMode {
    /// Resolved longest-edge target, clamped to at least one pixel.
    var longEdgePixels: Int {
        switch self {
        case let .longEdgePixels(pixels):
            max(1, pixels)
        }
    }

    /// Creates a longest-edge resize mode using the default target when omitted.
    init(longEdgePixels: Int = Self.defaultLongEdgePixels) {
        self = .longEdgePixels(longEdgePixels)
    }
}
