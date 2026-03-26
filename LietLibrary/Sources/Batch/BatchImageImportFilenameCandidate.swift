import Foundation

/// An original filename observed during photo import.
public struct BatchImageImportFilenameCandidate: Equatable, Sendable {
    /// The photo-library resource category that produced the filename.
    public let resourceKind: BatchImageImportResourceKind
    /// The original filename supplied by the importer.
    public let originalFilename: String

    /// Creates a filename candidate for import policy evaluation.
    public init(
        resourceKind: BatchImageImportResourceKind,
        originalFilename: String
    ) {
        self.resourceKind = resourceKind
        self.originalFilename = originalFilename
    }
}
