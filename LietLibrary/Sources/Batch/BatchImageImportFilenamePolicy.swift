import Foundation

/// Shared rules for picking the original filename during photo import.
public enum BatchImageImportFilenamePolicy {
    /// Picks the best original filename from the available Photos resources.
    public static func preferredOriginalFilename(
        from candidates: [BatchImageImportFilenameCandidate]
    ) -> String? {
        let preferredPhotoResourceKinds: [BatchImageImportResourceKind] = [
            .photo,
            .fullSizePhoto,
            .alternatePhoto
        ]
        let usableCandidates: [BatchImageImportFilenameCandidate] = candidates.compactMap { candidate in
            let normalizedFilename = candidate.originalFilename
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !normalizedFilename.isEmpty,
                  allowsOriginalFilenameCandidate(candidate.resourceKind) else {
                return nil
            }

            return .init(
                resourceKind: candidate.resourceKind,
                originalFilename: normalizedFilename
            )
        }

        for preferredKind in preferredPhotoResourceKinds {
            if let candidate = usableCandidates.first(where: { candidate in
                candidate.resourceKind == preferredKind
            }) {
                return candidate.originalFilename
            }
        }

        return usableCandidates.first?.originalFilename
    }

    /// Normalizes a filename received from a transferred temporary file path.
    public static func originalFilename(
        fromTransferredFilename transferredFilename: String?
    ) -> String? {
        guard let transferredFilename else {
            return nil
        }

        let filename = URL(fileURLWithPath: transferredFilename)
            .lastPathComponent
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return filename.isEmpty ? nil : filename
    }

    /// Reports whether a resource kind is allowed to supply the original filename.
    public static func allowsOriginalFilenameCandidate(
        _ resourceKind: BatchImageImportResourceKind
    ) -> Bool {
        switch resourceKind {
        case .video,
             .audio,
             .fullSizeVideo,
             .adjustmentData,
             .pairedVideo,
             .fullSizePairedVideo,
             .adjustmentBasePairedVideo:
            false
        case .photo,
             .fullSizePhoto,
             .alternatePhoto,
             .other:
            true
        }
    }
}
