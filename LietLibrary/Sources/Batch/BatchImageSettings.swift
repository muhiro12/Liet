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
        compression: BatchImageCompression = .off
    ) {
        self.resizeMode = resizeMode
        self.compression = compression
    }
}

public extension BatchImageSettings {
    /// The configured width target.
    var widthPixels: Int {
        resizeMode.widthPixels
    }

    /// The configured height target.
    var heightPixels: Int {
        resizeMode.heightPixels
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
