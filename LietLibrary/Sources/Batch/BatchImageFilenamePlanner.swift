import Foundation

/// Internal filename planner used by `BatchImageFilenameOperations`.
struct BatchImageFilenamePlanner: Equatable, Sendable {
    typealias Item = BatchImageFilenameOperations.Item

    private var customFilenameStems: [UUID: String]

    /// Creates a planner with any previously edited custom stems.
    init(
        customFilenameStems: [UUID: String] = [:]
    ) {
        self.customFilenameStems = customFilenameStems
    }
}

extension BatchImageFilenamePlanner {
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
