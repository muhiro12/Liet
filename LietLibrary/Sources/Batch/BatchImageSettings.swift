import Foundation

/// Shared batch-processing settings applied to every selected image.
public struct BatchImageSettings: Equatable, Codable, Sendable {
    /// The resizing behavior used for the batch.
    public var resizeMode: BatchResizeMode
    /// The lossy compression preset used when the format supports it.
    public var compression: BatchImageCompression
    /// The output naming rules used for generated filenames.
    public var naming: BatchImageNaming

    /// Creates a batch settings value with the repository defaults.
    public init(
        resizeMode: BatchResizeMode = .default,
        compression: BatchImageCompression = .off,
        naming: BatchImageNaming = .default
    ) {
        self.resizeMode = resizeMode
        self.compression = compression
        self.naming = naming
    }
}

public extension BatchImageSettings {
    /// The configured reference edge when the resize mode preserves aspect ratio.
    var referenceDimension: BatchResizeReferenceDimension? {
        resizeMode.referenceDimension
    }

    /// The configured reference pixel value when the resize mode preserves aspect ratio.
    var referencePixels: Int? {
        resizeMode.referencePixels
    }

    /// The configured exact width target.
    var exactWidthPixels: Int? {
        resizeMode.exactWidthPixels
    }

    /// The configured exact height target.
    var exactHeightPixels: Int? {
        resizeMode.exactHeightPixels
    }

    /// The exact-size strategy when this setting targets both edges.
    var exactResizeStrategy: BatchExactResizeStrategy? {
        resizeMode.exactResizeStrategy
    }

    /// Whether the resize mode preserves the source aspect ratio.
    var keepsAspectRatio: Bool {
        resizeMode.keepsAspectRatio
    }
}
