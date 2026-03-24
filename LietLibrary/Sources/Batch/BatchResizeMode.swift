import Foundation

/// Resizing modes supported by the batch processor.
public enum BatchResizeMode: Equatable, Codable, Sendable {
    /// Resizes an image from a single reference edge while preserving aspect ratio.
    case fitWithin(
            referenceDimension: BatchResizeReferenceDimension,
            pixels: Int
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
    /// Default reference edge used by the app.
    public static let defaultReferenceDimension: BatchResizeReferenceDimension = .width
    /// Default reference pixel value used by the app.
    public static let defaultReferencePixels = defaultWidthPixels
    /// Default resize mode used by the app.
    public static let `default`: Self = .fitWithin(
        referenceDimension: defaultReferenceDimension,
        pixels: defaultReferencePixels
    )
}

public extension BatchResizeMode {
    /// The configured reference edge when the current mode preserves aspect ratio.
    var referenceDimension: BatchResizeReferenceDimension? {
        switch self {
        case let .fitWithin(referenceDimension, _):
            referenceDimension
        case .exactSize:
            nil
        }
    }

    /// The configured reference pixel value when the current mode preserves aspect ratio.
    var referencePixels: Int? {
        switch self {
        case let .fitWithin(_, pixels):
            max(1, pixels)
        case .exactSize:
            nil
        }
    }

    /// The configured exact width target.
    var exactWidthPixels: Int? {
        switch self {
        case .fitWithin:
            nil
        case let .exactSize(widthPixels, _, _):
            max(1, widthPixels)
        }
    }

    /// The configured exact height target.
    var exactHeightPixels: Int? {
        switch self {
        case .fitWithin:
            nil
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
        referenceDimension: BatchResizeReferenceDimension = Self.defaultReferenceDimension,
        pixels: Int = Self.defaultReferencePixels
    ) {
        self = .fitWithin(
            referenceDimension: referenceDimension,
            pixels: pixels
        )
    }
}
