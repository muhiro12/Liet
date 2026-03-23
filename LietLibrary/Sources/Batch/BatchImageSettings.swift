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
    /// Resolved long-edge pixel target for the current resize mode.
    var longEdgePixels: Int {
        resizeMode.longEdgePixels
    }
}
