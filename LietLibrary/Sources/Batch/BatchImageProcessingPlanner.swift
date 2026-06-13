import CoreGraphics
import Foundation

/// Internal pure planning logic used by `BatchImageProcessingOperations`.
enum BatchImageProcessingPlanner {
    typealias Source = BatchImageProcessingOperations.Source
    typealias Plan = BatchImageProcessingOperations.Plan
    typealias Summary = BatchImageProcessingOperations.Summary
}

extension BatchImageProcessingPlanner {
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
            heicEncoderAvailable: heicEncoderAvailable
        )
        let usedJPEGFallback = source.originalFormat.requiresOutputFallback ||
            (source.originalFormat == .heic && outputFormat == .jpeg)
        let ignoredCompressionSetting = outputFormat == .png &&
            settings.compression != .off
        let outputStem = settings.naming.filenameStem(
            for: source.selectionIndex
        ) ?? BatchImageNaming.default.filenameStem(
            for: source.selectionIndex
        ) ?? ProcessedImageNaming.fallbackStem
        let outputFilename = ProcessedImageNaming.makeFilename(
            stem: outputStem,
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
