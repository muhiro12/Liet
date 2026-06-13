import Foundation

/// Editable filename use cases called by delivery surfaces.
public struct BatchImageFilenameOperations: Equatable, Sendable {
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

    private var planner: BatchImageFilenamePlanner

    /// Creates filename operations with any previously edited custom stems.
    public init(
        customFilenameStems: [UUID: String] = [:]
    ) {
        planner = .init(
            customFilenameStems: customFilenameStems
        )
    }
}

public extension BatchImageFilenameOperations {
    /// Returns the editable stem currently shown for an item.
    func editableFilenameStem(
        for item: Item
    ) -> String {
        planner.editableFilenameStem(
            for: item
        )
    }

    /// Stores an edited stem after normalizing whitespace and duplicate extensions.
    mutating func setEditableFilenameStem(
        _ filenameStem: String,
        for item: Item
    ) {
        planner.setEditableFilenameStem(
            filenameStem,
            for: item
        )
    }

    /// Resolves the final unique filename for a single item within a result set.
    func resolvedFilename(
        for item: Item,
        within items: [Item]
    ) -> String {
        planner.resolvedFilename(
            for: item,
            within: items
        )
    }

    /// Resolves final unique filenames for every item in display order.
    func resolvedFilenames(
        for items: [Item]
    ) -> [UUID: String] {
        planner.resolvedFilenames(
            for: items
        )
    }
}
