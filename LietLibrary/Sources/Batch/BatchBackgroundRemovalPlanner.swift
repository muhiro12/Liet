import CoreGraphics
import Foundation

/// Internal pure planning logic used by `BatchBackgroundRemovalOperations`.
enum BatchBackgroundRemovalPlanner {
    typealias Source = BatchBackgroundRemovalOperations.Source
    typealias Plan = BatchBackgroundRemovalOperations.Plan
}

extension BatchBackgroundRemovalPlanner {
    /// Builds a full processing plan for one source image.
    static func makePlan(
        for source: Source,
        naming: BatchImageNaming,
        existingFilenames: Set<String> = []
    ) -> Plan {
        let outputStem = naming.filenameStem(
            for: source.selectionIndex
        ) ?? BatchImageNaming.default.filenameStem(
            for: source.selectionIndex
        ) ?? ProcessedImageNaming.fallbackStem
        let outputFormat: ImageFileFormat = .png
        let outputFilename = ProcessedImageNaming.makeFilename(
            stem: outputStem,
            outputFormat: outputFormat,
            existingFilenames: existingFilenames
        )

        return .init(
            outputFormat: outputFormat,
            outputFilename: outputFilename,
            outputPixelSize: source.originalPixelSize
        )
    }
}
