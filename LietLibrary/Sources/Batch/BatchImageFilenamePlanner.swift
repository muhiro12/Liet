import Foundation

/// Resolves editable output stems into unique filenames for batch results.
public struct BatchImageFilenamePlanner: Equatable, Sendable {
    /// A result item that needs a resolved output filename.
    public struct Item: Identifiable, Equatable, Sendable {
        /// Stable identity used to track per-item custom stems.
        public let id: UUID
        /// The default stem derived from the generated output name.
        public let defaultStem: String
        /// The output format that defines the exported filename extension.
        public let outputFormat: ImageFileFormat

        /// Creates a result item for filename planning.
        public init(
            id: UUID,
            defaultStem: String,
            outputFormat: ImageFileFormat
        ) {
            self.id = id
            self.defaultStem = defaultStem
            self.outputFormat = outputFormat
        }
    }

    private var customFilenameStems: [UUID: String]

    /// Creates a planner with any previously edited custom stems.
    public init(
        customFilenameStems: [UUID: String] = [:]
    ) {
        self.customFilenameStems = customFilenameStems
    }
}

public extension BatchImageFilenamePlanner {
    /// Returns the editable stem currently shown for an item.
    func editableFilenameStem(
        for item: Item
    ) -> String {
        customFilenameStems[item.id] ?? item.defaultStem
    }

    /// Stores an edited stem after normalizing whitespace and duplicate extensions.
    mutating func setEditableFilenameStem(
        _ filenameStem: String,
        for item: Item
    ) {
        customFilenameStems[item.id] = normalizedFilenameStem(
            filenameStem
        )
    }

    /// Resolves the final unique filename for a single item within a result set.
    func resolvedFilename(
        for item: Item,
        within items: [Item]
    ) -> String {
        resolvedFilenames(for: items)[item.id] ?? ProcessedImageNaming.makeFilename(
            stem: item.defaultStem,
            outputFormat: item.outputFormat
        )
    }

    /// Resolves final unique filenames for every item in display order.
    func resolvedFilenames(
        for items: [Item]
    ) -> [UUID: String] {
        var usedFilenames: Set<String> = []
        var resolvedFilenames: [UUID: String] = [:]

        for item in items {
            let filename = ProcessedImageNaming.makeFilename(
                stem: normalizedResolvedStem(for: item),
                outputFormat: item.outputFormat,
                existingFilenames: usedFilenames
            )
            usedFilenames.insert(filename)
            resolvedFilenames[item.id] = filename
        }

        return resolvedFilenames
    }
}

private extension BatchImageFilenamePlanner {
    func normalizedResolvedStem(
        for item: Item
    ) -> String {
        let customStem = normalizedFilenameStem(
            customFilenameStems[item.id] ?? ""
        )

        if customStem.isEmpty {
            return item.defaultStem
        }

        return customStem
    }

    func normalizedFilenameStem(
        _ filenameStem: String
    ) -> String {
        ProcessedImageNaming.normalizedFilenameStem(
            from: filenameStem
        )
    }
}
