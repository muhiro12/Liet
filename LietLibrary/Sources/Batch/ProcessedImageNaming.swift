import Foundation

/// Shared output naming rules for processed images.
public enum ProcessedImageNaming {
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
        let stem = resolvedStem(
            originalFilename: originalFilename,
            baseName: baseName
        )
        let fileExtension = outputFormat.filenameExtension
        let firstCandidate = "\(stem).\(fileExtension)"

        guard !existingFilenames.contains(firstCandidate) else {
            return numberedCandidate(
                stem: stem,
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

    static func resolvedStem(
        originalFilename: String?,
        baseName: String
    ) -> String {
        if originalFilename == nil {
            return baseName
        }

        return "\(baseName)-processed"
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
