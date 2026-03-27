import CoreGraphics
import Foundation

/// Shared pure planning logic used before rendering processed batch images.
public enum BatchImageProcessingPlanner {
    /// Source metadata required to produce an output plan.
    public struct Source: Equatable, Sendable {
        /// The preferred original filename when available.
        public let originalFilename: String?
        /// The source image format detected during import.
        public let originalFormat: ImageFileFormat
        /// The original pixel dimensions of the source image.
        public let originalPixelSize: CGSize
        /// The 1-based selection index used for fallback filenames.
        public let selectionIndex: Int

        /// Creates source metadata for pure processing decisions.
        public init(
            originalFilename: String?,
            originalFormat: ImageFileFormat,
            originalPixelSize: CGSize,
            selectionIndex: Int
        ) {
            self.originalFilename = originalFilename
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

public extension BatchImageProcessingPlanner {
    /// Resolves the final output format for a source image.
    static func resolvedOutputFormat(
        for originalFormat: ImageFileFormat,
        heicEncoderAvailable: Bool
    ) -> ImageFileFormat {
        let preferredOutputFormat = originalFormat.preferredOutputFormat

        if preferredOutputFormat == .heic,
           !heicEncoderAvailable {
            return .jpeg
        }

        return preferredOutputFormat
    }

    /// Resolves the final output format while considering batch settings.
    static func resolvedOutputFormat(
        for originalFormat: ImageFileFormat,
        settings: BatchImageSettings,
        heicEncoderAvailable: Bool
    ) -> ImageFileFormat {
        if settings.backgroundRemoval.isEnabled {
            return .png
        }

        return resolvedOutputFormat(
            for: originalFormat,
            heicEncoderAvailable: heicEncoderAvailable
        )
    }

    /// Projects the output pixel size for a source image under the selected resize mode.
    static func projectedPixelSize(
        originalPixelSize: CGSize,
        resizeMode: BatchResizeMode
    ) -> CGSize {
        switch resizeMode {
        case let .fitWithin(referenceDimension, pixels):
            fitWithinPixelSize(
                originalPixelSize: originalPixelSize,
                referenceDimension: referenceDimension,
                referencePixels: pixels
            )
        case let .exactSize(widthPixels, heightPixels, _):
            exactCanvasPixelSize(
                widthPixels: widthPixels,
                heightPixels: heightPixels
            )
        }
    }

    /// Calculates the target size for aspect-ratio-preserving resizing.
    static func fitWithinPixelSize(
        originalPixelSize: CGSize,
        referenceDimension: BatchResizeReferenceDimension,
        referencePixels: Int
    ) -> CGSize {
        let targetPixels = CGFloat(max(1, referencePixels))
        let referenceLength: CGFloat = switch referenceDimension {
        case .width:
            max(minimumPixelDimension, originalPixelSize.width)
        case .height:
            max(minimumPixelDimension, originalPixelSize.height)
        }
        let scale = min(1, targetPixels / referenceLength)

        return .init(
            width: max(minimumPixelDimension, ceil(originalPixelSize.width * scale)),
            height: max(minimumPixelDimension, ceil(originalPixelSize.height * scale))
        )
    }

    /// Calculates the exact output canvas size from explicit width and height values.
    static func exactCanvasPixelSize(
        widthPixels: Int,
        heightPixels: Int
    ) -> CGSize {
        .init(
            width: CGFloat(max(1, widthPixels)),
            height: CGFloat(max(1, heightPixels))
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
        guard settings.backgroundRemoval.isEnabled == false else {
            return false
        }

        guard case .fitWithin = settings.resizeMode else {
            return false
        }

        guard outputFormat == originalFormat else {
            return false
        }

        let preservesSourceData = settings.compression == .off ||
            !outputFormat.supportsLossyCompressionQuality

        guard preservesSourceData else {
            return false
        }

        let resolvedTargetPixelSize = targetPixelSize ?? projectedPixelSize(
            originalPixelSize: originalPixelSize,
            resizeMode: settings.resizeMode
        )

        return Int(resolvedTargetPixelSize.width) == Int(originalPixelSize.width) &&
            Int(resolvedTargetPixelSize.height) == Int(originalPixelSize.height)
    }

    /// Builds a full processing plan for one source image.
    static func makePlan(
        for source: Source,
        settings: BatchImageSettings,
        heicEncoderAvailable: Bool,
        existingFilenames: Set<String> = []
    ) -> Plan {
        let outputFormat = resolvedOutputFormat(
            for: source.originalFormat,
            settings: settings,
            heicEncoderAvailable: heicEncoderAvailable
        )
        let usedJPEGFallback = settings.backgroundRemoval.isEnabled == false &&
            (
                source.originalFormat.requiresOutputFallback ||
                    (source.originalFormat == .heic && outputFormat == .jpeg)
            )
        let ignoredCompressionSetting = outputFormat == .png &&
            settings.compression != .off
        let outputFilename = ProcessedImageNaming.makeFilename(
            originalFilename: source.originalFilename,
            fallbackIndex: source.selectionIndex,
            outputFormat: outputFormat,
            existingFilenames: existingFilenames
        )
        let outputPixelSize = projectedPixelSize(
            originalPixelSize: source.originalPixelSize,
            resizeMode: settings.resizeMode
        )

        return .init(
            outputFormat: outputFormat,
            outputFilename: outputFilename,
            outputPixelSize: outputPixelSize,
            usedJPEGFallback: usedJPEGFallback,
            ignoredCompressionSetting: ignoredCompressionSetting,
            shouldCopyOriginal: shouldCopyOriginal(
                originalFormat: source.originalFormat,
                originalPixelSize: source.originalPixelSize,
                settings: settings,
                outputFormat: outputFormat,
                targetPixelSize: outputPixelSize
            )
        )
    }

    /// Summarizes fallback and compression behavior across the batch.
    static func summarize(
        plans: [Plan]
    ) -> Summary {
        .init(
            jpegFallbackCount: plans.filter(\.usedJPEGFallback).count,
            ignoredCompressionCount: plans.filter(\.ignoredCompressionSetting).count
        )
    }
}

private extension BatchImageProcessingPlanner {
    static let minimumPixelDimension = CGFloat(1)
}
