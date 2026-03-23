import Foundation

public struct BatchImageSettings: Equatable, Codable, Sendable {
    public var resizeMode: BatchResizeMode
    public var compression: BatchImageCompression

    public init(
        resizeMode: BatchResizeMode = .default,
        compression: BatchImageCompression = .medium
    ) {
        self.resizeMode = resizeMode
        self.compression = compression
    }
}

public extension BatchImageSettings {
    var longEdgePixels: Int {
        resizeMode.longEdgePixels
    }
}
