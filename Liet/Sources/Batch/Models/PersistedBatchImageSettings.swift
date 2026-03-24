import LietLibrary

struct PersistedBatchImageSettings: Codable, Equatable {
    static let `default`: Self = .init(
        resizeMode: .aspectRatioPreserved,
        referenceDimension: BatchResizeMode.defaultReferenceDimension,
        referencePixels: BatchResizeMode.defaultReferencePixels,
        exactWidthPixels: BatchResizeMode.defaultWidthPixels,
        exactHeightPixels: BatchResizeMode.defaultHeightPixels,
        exactResizeStrategy: .stretch,
        compression: .off
    )

    var resizeMode: PersistedBatchResizeMode
    var referenceDimension: BatchResizeReferenceDimension
    var referencePixels: Int
    var exactWidthPixels: Int
    var exactHeightPixels: Int
    var exactResizeStrategy: BatchExactResizeStrategy
    var compression: BatchImageCompression
}
