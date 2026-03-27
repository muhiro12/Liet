import CoreGraphics
import Foundation
import LietLibrary

enum BatchBackgroundRemovalProcessor {
    typealias Outcome = BatchImageProcessor.Outcome
}

extension BatchBackgroundRemovalProcessor {
    // swiftlint:disable:next function_body_length
    nonisolated static func process(
        images: [ImportedBatchImage],
        settings: BatchBackgroundRemovalSettings,
        naming: BatchImageNaming
    ) -> Outcome {
        guard !images.isEmpty else {
            return .init(
                processedImages: [],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        }

        let outputDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(
            "LietBackgroundRemoved-\(UUID().uuidString)",
            isDirectory: true
        )

        do {
            try FileManager.default.createDirectory(
                at: outputDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            return .init(
                processedImages: [],
                failureCount: images.count,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        }

        var processedImages: [ProcessedBatchImage] = []
        var usedFilenames: Set<String> = []
        var failureCount = 0

        for image in images {
            do {
                let plan = BatchBackgroundRemovalPlanner.makePlan(
                    for: .init(
                        originalPixelSize: image.pixelSize,
                        selectionIndex: image.selectionIndex
                    ),
                    naming: naming,
                    existingFilenames: usedFilenames
                )
                usedFilenames.insert(plan.outputFilename)
                let outputURL = outputDirectory.appendingPathComponent(
                    plan.outputFilename
                )
                let renderedImage = try renderedImage(
                    from: image.sourceURL,
                    settings: settings
                )
                try BatchImageProcessor.writeImage(
                    renderedImage.cgImage,
                    format: plan.outputFormat,
                    compression: .off,
                    outputURL: outputURL
                )
                let previewImage = try ImageIOImageSupport.previewImage(from: outputURL)
                processedImages.append(
                    .init(
                        sourceID: image.id,
                        outputURL: outputURL,
                        outputFilename: plan.outputFilename,
                        outputFormat: plan.outputFormat,
                        originalFormat: image.originalFormat,
                        pixelSize: renderedImage.pixelSize,
                        previewImage: previewImage,
                        usedJPEGFallback: false,
                        ignoredCompressionSetting: false
                    )
                )
            } catch {
                failureCount += 1
            }
        }

        return .init(
            processedImages: processedImages,
            failureCount: failureCount,
            jpegFallbackCount: 0,
            ignoredCompressionCount: 0
        )
    }

    nonisolated static func renderedImage(
        from sourceURL: URL,
        settings: BatchBackgroundRemovalSettings
    ) throws -> BatchImageProcessor.RenderedImage {
        let imageSource = try ImageIOImageSupport.imageSource(url: sourceURL)
        let originalPixelSize = try ImageIOImageSupport.pixelSize(from: imageSource)
        let sourceImage = try ImageIOImageSupport.cgImage(
            from: imageSource,
            maxPixelSize: ImageIOImageSupport.maxPixelSize(
                for: originalPixelSize
            )
        )
        let outputImage = try BatchBackgroundRemovalService.removedBackgroundImage(
            from: sourceImage,
            settings: settings
        )

        return .init(
            cgImage: outputImage,
            pixelSize: .init(
                width: outputImage.width,
                height: outputImage.height
            )
        )
    }
}
