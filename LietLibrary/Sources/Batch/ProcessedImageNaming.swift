import Foundation

/// Shared output naming rules for processed images.
public enum ProcessedImageNaming {
    static let fallbackStem = "image"

    /// Builds a unique output filename from an explicit stem.
    public static func makeFilename(
        stem: String,
        outputFormat: ImageFileFormat,
        existingFilenames: Set<String> = []
    ) -> String {
        let normalizedStem = normalizedStem(from: stem)
        let fileExtension = outputFormat.filenameExtension
        let firstCandidate = "\(normalizedStem).\(fileExtension)"

        guard !existingFilenames.contains(firstCandidate) else {
            return numberedCandidate(
                stem: normalizedStem,
                fileExtension: fileExtension,
                existingFilenames: existingFilenames
            )
        }

        return firstCandidate
    }
}

extension ProcessedImageNaming {
    static func normalizedFilenameStem(
        from stem: String
    ) -> String {
        let trimmedStem = stem
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedStem.isEmpty else {
            return ""
        }

        return strippedTrailingImageExtensions(from: trimmedStem)
    }
}

private extension ProcessedImageNaming {
    static let removableImageExtensions: Set<String> = [
        "heic",
        "heif",
        "jpeg",
        "jpg",
        "png"
    ]

    static func normalizedStem(
        from stem: String
    ) -> String {
        let normalizedStem = normalizedFilenameStem(
            from: stem
        )

        if normalizedStem.isEmpty {
            return fallbackStem
        }

        return normalizedStem
    }

    static func strippedTrailingImageExtensions(
        from stem: String
    ) -> String {
        var candidate = stem

        while true {
            guard let extensionSeparator = candidate.lastIndex(of: ".") else {
                return candidate
            }
            let extensionStart = candidate.index(after: extensionSeparator)
            let pathExtension = candidate[extensionStart...].lowercased()

            guard removableImageExtensions.contains(pathExtension),
                  !pathExtension.isEmpty else {
                return candidate
            }

            let nextCandidate = String(
                candidate[..<extensionSeparator]
            )

            guard nextCandidate != candidate else {
                return candidate
            }

            candidate = nextCandidate
        }
    }

    static func numberedCandidate(
        stem: String,
        fileExtension: String,
        existingFilenames: Set<String>
    ) -> String {
        var index = 2

        while true {
            let candidate = "\(stem)-\(index).\(fileExtension)"

            if !existingFilenames.contains(candidate) {
                return candidate
            }

            index += 1
        }
    }
}
