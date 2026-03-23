import Foundation

/// Resizing modes supported by the MVP batch processor.
public enum BatchResizeMode: Equatable, Codable, Sendable {
    /// Scales an image so its longest edge matches the provided pixel value.
    case longEdgePixels(Int)
    /// Scales an image so its shortest edge matches the provided pixel value.
    case shortEdgePixels(Int)
    /// Fits or crops an image into a canvas that fixes both edges.
    case exactSize(
            longEdgePixels: Int,
            shortEdgePixels: Int,
            strategy: BatchExactResizeStrategy
         )

    /// Default longest-edge target used by the app.
    public static let defaultLongEdgePixels = 1_920
    /// Default resize mode used by the app.
    public static let `default`: Self = .longEdgePixels(defaultLongEdgePixels)
}

public extension BatchResizeMode {
    /// The configured long edge for long-edge and exact-size resizing.
    var longEdgePixels: Int? {
        switch self {
        case let .longEdgePixels(pixels):
            max(1, pixels)
        case let .exactSize(longEdgePixels, _, _):
            max(1, longEdgePixels)
        case .shortEdgePixels:
            nil
        }
    }

    /// The configured short edge for short-edge and exact-size resizing.
    var shortEdgePixels: Int? {
        switch self {
        case let .shortEdgePixels(pixels):
            max(1, pixels)
        case let .exactSize(_, shortEdgePixels, _):
            max(1, shortEdgePixels)
        case .longEdgePixels:
            nil
        }
    }

    /// The exact-size strategy when this mode targets both edges.
    var exactResizeStrategy: BatchExactResizeStrategy? {
        switch self {
        case let .exactSize(_, _, strategy):
            strategy
        case .longEdgePixels, .shortEdgePixels:
            nil
        }
    }

    /// Creates a longest-edge resize mode using the default target when omitted.
    init(longEdgePixels: Int = Self.defaultLongEdgePixels) {
        self = .longEdgePixels(longEdgePixels)
    }
}
