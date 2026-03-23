import Foundation

/// Resizing modes supported by the batch processor.
public enum BatchResizeMode: Equatable, Codable, Sendable {
    /// Fits an image inside the provided bounding box while preserving aspect ratio.
    case fitWithin(
            widthPixels: Int,
            heightPixels: Int
         )
    /// Renders an image into a fixed canvas using the provided strategy.
    case exactSize(
            widthPixels: Int,
            heightPixels: Int,
            strategy: BatchExactResizeStrategy
         )

    /// Default output width used by the app.
    public static let defaultWidthPixels = 1_920
    /// Default output height used by the app.
    public static let defaultHeightPixels = 1_080
    /// Default resize mode used by the app.
    public static let `default`: Self = .fitWithin(
        widthPixels: defaultWidthPixels,
        heightPixels: defaultHeightPixels
    )
}

public extension BatchResizeMode {
    /// The configured width target for the current mode.
    var widthPixels: Int {
        switch self {
        case let .fitWithin(widthPixels, _):
            max(1, widthPixels)
        case let .exactSize(widthPixels, _, _):
            max(1, widthPixels)
        }
    }

    /// The configured height target for the current mode.
    var heightPixels: Int {
        switch self {
        case let .fitWithin(_, heightPixels):
            max(1, heightPixels)
        case let .exactSize(_, heightPixels, _):
            max(1, heightPixels)
        }
    }

    /// The exact-size strategy when this mode targets both edges.
    var exactResizeStrategy: BatchExactResizeStrategy? {
        switch self {
        case let .exactSize(_, _, strategy):
            strategy
        case .fitWithin:
            nil
        }
    }

    /// Whether the mode keeps the source aspect ratio.
    var keepsAspectRatio: Bool {
        switch self {
        case .fitWithin:
            true
        case .exactSize:
            false
        }
    }

    /// Creates an aspect-ratio-preserving resize mode using app defaults when omitted.
    init(
        widthPixels: Int = Self.defaultWidthPixels,
        heightPixels: Int = Self.defaultHeightPixels
    ) {
        self = .fitWithin(
            widthPixels: widthPixels,
            heightPixels: heightPixels
        )
    }
}
