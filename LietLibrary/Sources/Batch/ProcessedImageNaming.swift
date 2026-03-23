import Foundation

/// Shared output naming rules for processed images.
public enum ProcessedImageNaming {
    /// App-specific suffix appended to processed image names.
    public static let appSuffix = "Liet"

    /// Builds a unique output filename for a processed image.
    public static func makeFilename(
        originalFilename: String?,
        fallbackIndex: Int,
        outputFormat: ImageFileFormat,
        existingFilenames: Set<String> = []
    ) -> String {
        let baseName = resolvedBaseName(
            originalFilename: originalFilename,
            fallbackIndex: fallbackIndex
        )

        return makeFilename(
            stem: "\(baseName)-\(appSuffix)",
            outputFormat: outputFormat,
            existingFilenames: existingFilenames
        )
    }

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

private extension ProcessedImageNaming {
    static func resolvedBaseName(
        originalFilename: String?,
        fallbackIndex: Int
    ) -> String {
        if let originalFilename,
           !originalFilename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let baseName = URL(fileURLWithPath: originalFilename)
                .deletingPathExtension()
                .lastPathComponent
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if !baseName.isEmpty {
                return baseName
            }
        }

        return String(
            format: "image-%03d",
            max(1, fallbackIndex)
        )
    }

    static func normalizedStem(
        from stem: String
    ) -> String {
        let trimmedStem = stem
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedStem.isEmpty {
            return appSuffix
        }

        return trimmedStem
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
