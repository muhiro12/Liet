import Foundation
import LietLibrary
import UIKit

enum BatchImagePreviewFixture {
    static let landscapeWidth = 1_600.0
    static let landscapeHeight = 900.0
    static let portraitWidth = 900.0
    static let portraitHeight = 1_600.0
    static let outputLandscapeWidth = 1_080.0
    static let outputLandscapeHeight = 608.0
    static let outputPortraitWidth = 1_080.0
    static let outputPortraitHeight = 1_920.0
    static let landscapeSize: CGSize = .init(
        width: landscapeWidth,
        height: landscapeHeight
    )
    static let portraitSize: CGSize = .init(
        width: portraitWidth,
        height: portraitHeight
    )
    static let outputLandscapeSize: CGSize = .init(
        width: outputLandscapeWidth,
        height: outputLandscapeHeight
    )
    static let outputPortraitSize: CGSize = .init(
        width: outputPortraitWidth,
        height: outputPortraitHeight
    )
    static let firstSelectionIndex = 1
    static let secondSelectionIndex = 2
    static let transparentSubjectCornerRadiusRatio = 0.08
    static let transparentSubjectInsetRatio = 0.18
    static let importedImages: [ImportedBatchImage] = [
        makeImportedImage(
            filename: "preview-landscape.jpg",
            format: .jpeg,
            size: landscapeSize,
            selectionIndex: firstSelectionIndex,
            color: .systemTeal
        ),
        makeImportedImage(
            filename: "preview-portrait.png",
            format: .png,
            size: portraitSize,
            selectionIndex: secondSelectionIndex,
            color: .systemOrange
        )
    ]
    static let processedImages: [ProcessedBatchImage] = [
        makeProcessedImage(
            filename: "IMG_001.jpeg",
            format: .jpeg,
            originalFormat: .jpeg,
            size: outputLandscapeSize,
            color: .systemTeal
        ),
        makeProcessedImage(
            filename: "IMG_002.png",
            format: .png,
            originalFormat: .png,
            size: outputPortraitSize,
            color: .systemOrange
        )
    ]
    static let backgroundRemovedImages: [ProcessedBatchImage] = [
        makeProcessedImage(
            filename: "IMG_001.png",
            format: .png,
            originalFormat: .jpeg,
            size: landscapeSize,
            color: .systemTeal,
            isTransparent: true
        ),
        makeProcessedImage(
            filename: "IMG_002.png",
            format: .png,
            originalFormat: .png,
            size: portraitSize,
            color: .systemOrange,
            isTransparent: true
        )
    ]

    static var importedPreviewItem: BatchImagePreviewItem {
        .init(
            importedImage: importedImages[0]
        )
    }

    static var importedFullscreenPreviewImage: UIImage {
        fullScreenPreviewImage(
            for: importedPreviewItem
        )
    }

    static var processedPreviewItem: BatchImagePreviewItem {
        .init(
            processedImage: processedImages[0]
        )
    }

    static var processedFullscreenPreviewImage: UIImage {
        fullScreenPreviewImage(
            for: processedPreviewItem
        )
    }

    static var transparentProcessedPreviewItem: BatchImagePreviewItem {
        .init(
            processedImage: backgroundRemovedImages[0]
        )
    }

    static var transparentFullscreenPreviewImage: UIImage {
        fullScreenPreviewImage(
            for: transparentProcessedPreviewItem
        )
    }
}

private extension BatchImagePreviewFixture {
    static let temporaryDirectory = FileManager.default.temporaryDirectory

    static func makeImportedImage(
        filename: String,
        format: ImageFileFormat,
        size: CGSize,
        selectionIndex: Int,
        color: UIColor
    ) -> ImportedBatchImage {
        let previewImage = makePreviewImage(
            size: size,
            color: color
        )
        let fileURL = makePreviewFileURL(
            filename: filename,
            image: previewImage,
            format: format
        )

        return .init(
            sourceURL: fileURL,
            originalFilename: filename,
            originalFormat: format,
            pixelSize: size,
            previewImage: previewImage,
            selectionIndex: selectionIndex
        )
    }

    static func makeProcessedImage(
        filename: String,
        format: ImageFileFormat,
        originalFormat: ImageFileFormat,
        size: CGSize,
        color: UIColor,
        isTransparent: Bool = false
    ) -> ProcessedBatchImage {
        let previewImage = makePreviewImage(
            size: size,
            color: color,
            isTransparent: isTransparent
        )
        let fileURL = makePreviewFileURL(
            filename: filename,
            image: previewImage,
            format: format
        )

        return .init(
            sourceID: .init(),
            outputURL: fileURL,
            outputFilename: filename,
            outputFormat: format,
            originalFormat: originalFormat,
            pixelSize: size,
            previewImage: previewImage,
            usedJPEGFallback: false,
            ignoredCompressionSetting: false
        )
    }

    static func makePreviewImage(
        size: CGSize,
        color: UIColor,
        isTransparent: Bool = false
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = !isTransparent

        return UIGraphicsImageRenderer(
            size: size,
            format: format
        ).image { context in
            let fullBounds = CGRect(
                origin: .zero,
                size: size
            )

            if isTransparent {
                UIColor.clear.setFill()
                context.fill(fullBounds)

                color.setFill()
                UIBezierPath(
                    roundedRect: transparentSubjectRect(
                        in: fullBounds
                    ),
                    cornerRadius: transparentSubjectCornerRadius(
                        in: fullBounds
                    )
                ).fill()
            } else {
                color.setFill()
                context.fill(fullBounds)
            }
        }
    }

    static func makePreviewFileURL(
        filename: String,
        image: UIImage,
        format: ImageFileFormat
    ) -> URL {
        let fileURL = temporaryDirectory.appendingPathComponent(filename)
        let data: Data? = switch format {
        case .png:
            image.pngData()
        case .jpeg, .heic, .other:
            image.jpegData(compressionQuality: 1)
        }

        if let data {
            try? data.write(
                to: fileURL,
                options: .atomic
            )
        }

        return fileURL
    }

    static func fullScreenPreviewImage(
        for item: BatchImagePreviewItem
    ) -> UIImage {
        guard let image = try? ImageIOImageSupport.fullScreenPreviewImage(
            from: item.imageURL,
            originalPixelSize: item.pixelSize
        ) else {
            preconditionFailure(
                "Failed to load preview image for \(item.displayName)"
            )
        }

        return image
    }

    static func transparentSubjectRect(
        in bounds: CGRect
    ) -> CGRect {
        bounds.insetBy(
            dx: bounds.width * transparentSubjectInsetRatio,
            dy: bounds.height * transparentSubjectInsetRatio
        )
    }

    static func transparentSubjectCornerRadius(
        in bounds: CGRect
    ) -> CGFloat {
        min(
            bounds.width,
            bounds.height
        ) * transparentSubjectCornerRadiusRatio
    }
}
