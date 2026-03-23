import Foundation

/// Shared batch-processing settings applied to every selected image.
public struct BatchImageSettings: Equatable, Codable, Sendable {
    /// The resizing behavior used for the batch.
    public var resizeMode: BatchResizeMode
    /// The lossy compression preset used when the format supports it.
    public var compression: BatchImageCompression

    /// Creates a batch settings value with the repository defaults.
    public init(
        resizeMode: BatchResizeMode = .default,
        compression: BatchImageCompression = .medium
    ) {
        self.resizeMode = resizeMode
        self.compression = compression
    }
}

public extension BatchImageSettings {
    /// The configured long edge for long-edge and exact-size resizing.
    var longEdgePixels: Int? {
        resizeMode.longEdgePixels
    }

    /// The configured short edge for short-edge and exact-size resizing.
    var shortEdgePixels: Int? {
        resizeMode.shortEdgePixels
    }

    /// The exact-size strategy when this setting targets both edges.
    var exactResizeStrategy: BatchExactResizeStrategy? {
        resizeMode.exactResizeStrategy
    }
}
