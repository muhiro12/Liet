import CoreGraphics
import Foundation

/// Batch-image processing use cases called by delivery surfaces.
public enum BatchImageProcessingOperations {
    /// Source metadata required to produce an output plan.
    public struct Source: Equatable, Sendable {
        /// The source image format detected during import.
        public let originalFormat: ImageFileFormat
        /// The original pixel dimensions of the source image.
        public let originalPixelSize: CGSize
        /// The 1-based selection index used for fallback filenames.
        public let selectionIndex: Int

        /// Creates source metadata for pure processing decisions.
        public init(
            originalFormat: ImageFileFormat,
            originalPixelSize: CGSize,
            selectionIndex: Int
        ) {
            self.originalFormat = originalFormat
            self.originalPixelSize = originalPixelSize
            self.selectionIndex = selectionIndex
        }
    }

    /// The resolved processing decisions for one source image.
    public struct Plan: Equatable, Sendable {
        /// The final output format after fallback rules are applied.
        public let outputFormat: ImageFileFormat
        /// The unique output filename chosen for export.
        public let outputFilename: String
        /// The target pixel size to render or preserve.
        public let outputPixelSize: CGSize
        /// Whether the requested HEIC output fell back to JPEG.
        public let usedJPEGFallback: Bool
        /// Whether the selected compression preset had no effect.
        public let ignoredCompressionSetting: Bool
        /// Whether the original file can be copied without re-rendering.
        public let shouldCopyOriginal: Bool

        /// Creates a resolved plan for one source image.
        public init(
            outputFormat: ImageFileFormat,
            outputFilename: String,
            outputPixelSize: CGSize,
            usedJPEGFallback: Bool,
            ignoredCompressionSetting: Bool,
            shouldCopyOriginal: Bool
        ) {
            self.outputFormat = outputFormat
            self.outputFilename = outputFilename
            self.outputPixelSize = outputPixelSize
            self.usedJPEGFallback = usedJPEGFallback
            self.ignoredCompressionSetting = ignoredCompressionSetting
            self.shouldCopyOriginal = shouldCopyOriginal
        }
    }

    /// Aggregated counters derived from a batch of processing plans.
    public struct Summary: Equatable, Sendable {
        /// The number of plans that required a JPEG fallback.
        public let jpegFallbackCount: Int
        /// The number of plans where compression settings were ignored.
        public let ignoredCompressionCount: Int

        /// Creates summary counters for a batch of processing plans.
        public init(
            jpegFallbackCount: Int,
            ignoredCompressionCount: Int
        ) {
            self.jpegFallbackCount = jpegFallbackCount
            self.ignoredCompressionCount = ignoredCompressionCount
        }
    }
}

public extension BatchImageProcessingOperations {
    /// Resolves the final output format for a source image.
    static func resolvedOutputFormat(
        for originalFormat: ImageFileFormat,
        heicEncoderAvailable: Bool
    ) -> ImageFileFormat {
        BatchImageProcessingPlanner.resolvedOutputFormat(
            for: originalFormat,
            heicEncoderAvailable: heicEncoderAvailable
        )
    }

    /// Projects the output pixel size for a source image under the selected resize mode.
    static func projectedPixelSize(
        originalPixelSize: CGSize,
        resizeMode: BatchResizeMode
    ) -> CGSize {
        BatchImageProcessingPlanner.projectedPixelSize(
            originalPixelSize: originalPixelSize,
            resizeMode: resizeMode
        )
    }

    /// Calculates the target size for aspect-ratio-preserving resizing.
    static func fitWithinPixelSize(
        originalPixelSize: CGSize,
        referenceDimension: BatchResizeReferenceDimension,
        referencePixels: Int
    ) -> CGSize {
        BatchImageProcessingPlanner.fitWithinPixelSize(
            originalPixelSize: originalPixelSize,
            referenceDimension: referenceDimension,
            referencePixels: referencePixels
        )
    }

    /// Calculates the exact output canvas size from explicit width and height values.
    static func exactCanvasPixelSize(
        widthPixels: Int,
        heightPixels: Int
    ) -> CGSize {
        BatchImageProcessingPlanner.exactCanvasPixelSize(
            widthPixels: widthPixels,
            heightPixels: heightPixels
        )
    }

    /// Reports whether the source file can be copied without re-encoding.
    static func shouldCopyOriginal(
        originalFormat: ImageFileFormat,
        originalPixelSize: CGSize,
        settings: BatchImageSettings,
        outputFormat: ImageFileFormat,
        targetPixelSize: CGSize? = nil
    ) -> Bool {
        BatchImageProcessingPlanner.shouldCopyOriginal(
            originalFormat: originalFormat,
            originalPixelSize: originalPixelSize,
            settings: settings,
            outputFormat: outputFormat,
            targetPixelSize: targetPixelSize
        )
    }

    /// Builds a full processing plan for one source image.
    static func makePlan(
        for source: Source,
        settings: BatchImageSettings,
        heicEncoderAvailable: Bool,
        existingFilenames: Set<String> = []
    ) -> Plan {
        BatchImageProcessingPlanner.makePlan(
            for: source,
            settings: settings,
            heicEncoderAvailable: heicEncoderAvailable,
            existingFilenames: existingFilenames
        )
    }

    /// Summarizes fallback and compression behavior across the batch.
    static func summarize(
        plans: [Plan]
    ) -> Summary {
        BatchImageProcessingPlanner.summarize(
            plans: plans
        )
    }
}
