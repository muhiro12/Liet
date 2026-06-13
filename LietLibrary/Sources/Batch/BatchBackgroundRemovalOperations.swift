import CoreGraphics
import Foundation

/// Background-removal processing use cases called by delivery surfaces.
public enum BatchBackgroundRemovalOperations {
    /// Source metadata required to produce an output plan.
    public struct Source: Equatable, Sendable {
        /// The original pixel dimensions of the source image.
        public let originalPixelSize: CGSize
        /// The 1-based selection index used for fallback filenames.
        public let selectionIndex: Int

        /// Creates source metadata for pure processing decisions.
        public init(
            originalPixelSize: CGSize,
            selectionIndex: Int
        ) {
            self.originalPixelSize = originalPixelSize
            self.selectionIndex = selectionIndex
        }
    }

    /// The resolved processing decisions for one source image.
    public struct Plan: Equatable, Sendable {
        /// The final output format for background-removed images.
        public let outputFormat: ImageFileFormat
        /// The unique output filename chosen for export.
        public let outputFilename: String
        /// The target pixel size to render.
        public let outputPixelSize: CGSize

        /// Creates a resolved plan for one source image.
        public init(
            outputFormat: ImageFileFormat,
            outputFilename: String,
            outputPixelSize: CGSize
        ) {
            self.outputFormat = outputFormat
            self.outputFilename = outputFilename
            self.outputPixelSize = outputPixelSize
        }
    }
}

public extension BatchBackgroundRemovalOperations {
    /// Builds a full processing plan for one source image.
    static func makePlan(
        for source: Source,
        naming: BatchImageNaming,
        existingFilenames: Set<String> = []
    ) -> Plan {
        BatchBackgroundRemovalPlanner.makePlan(
            for: source,
            naming: naming,
            existingFilenames: existingFilenames
        )
    }
}
