import Foundation

/// Image import naming use cases called by delivery surfaces.
public enum BatchImageImportOperations {
    /// Picks the best original filename from the available Photos resources.
    public static func preferredOriginalFilename(
        from candidates: [BatchImageImportFilenameCandidate]
    ) -> String? {
        BatchImageImportFilenamePolicy.preferredOriginalFilename(
            from: candidates
        )
    }

    /// Normalizes a filename received from a transferred temporary file path.
    public static func originalFilename(
        fromTransferredFilename transferredFilename: String?
    ) -> String? {
        BatchImageImportFilenamePolicy.originalFilename(
            fromTransferredFilename: transferredFilename
        )
    }

    /// Reports whether a resource kind is allowed to supply the original filename.
    public static func allowsOriginalFilenameCandidate(
        _ resourceKind: BatchImageImportResourceKind
    ) -> Bool {
        BatchImageImportFilenamePolicy.allowsOriginalFilenameCandidate(
            resourceKind
        )
    }
}
