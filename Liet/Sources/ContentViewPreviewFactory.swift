import LietLibrary
import SwiftUI
import UIKit

#Preview("iPhone Imported") {
    ContentView(
        model: .previewImported(),
        preferredCompactColumn: .detail
    )
}

#Preview("iPhone Result") {
    ContentView(
        model: .previewProcessed(),
        preferredCompactColumn: .detail
    )
}

#Preview(
    "iPad Imported",
    traits: .fixedLayout(
        width: ContentViewPreviewFactory.iPadPreviewWidth,
        height: ContentViewPreviewFactory.iPadPreviewHeight
    )
) {
    ContentView(
        model: .previewImported()
    )
}

#Preview(
    "iPad Result",
    traits: .fixedLayout(
        width: ContentViewPreviewFactory.iPadPreviewWidth,
        height: ContentViewPreviewFactory.iPadPreviewHeight
    )
) {
    ContentView(
        model: .previewProcessed()
    )
}

private enum ContentViewPreviewFactory {
    static let iPadPreviewWidth = 1_194.0
    static let iPadPreviewHeight = 834.0
    static let landscapeWidth = 1_600.0
    static let landscapeHeight = 900.0
    static let portraitWidth = 900.0
    static let portraitHeight = 1_600.0
    static let outputLandscapeWidth = 1_080.0
    static let outputLandscapeHeight = 608.0
    static let outputPortraitWidth = 1_080.0
    static let outputPortraitHeight = 1_920.0
    static let firstSelectionIndex = 1
    static let secondSelectionIndex = 2

    private static let temporaryDirectory = FileManager.default.temporaryDirectory

    static let importedImages: [ImportedBatchImage] = [
        makeImportedImage(
            filename: "preview-landscape.jpg",
            format: .jpeg,
            size: .init(
                width: landscapeWidth,
                height: landscapeHeight
            ),
            selectionIndex: firstSelectionIndex,
            color: .systemTeal
        ),
        makeImportedImage(
            filename: "preview-portrait.png",
            format: .png,
            size: .init(
                width: portraitWidth,
                height: portraitHeight
            ),
            selectionIndex: secondSelectionIndex,
            color: .systemOrange
        )
    ]

    static let processedImages: [ProcessedBatchImage] = [
        makeProcessedImage(
            filename: "IMG_001.jpeg",
            format: .jpeg,
            originalFormat: .jpeg,
            size: .init(
                width: outputLandscapeWidth,
                height: outputLandscapeHeight
            ),
            color: .systemTeal
        ),
        makeProcessedImage(
            filename: "IMG_002.png",
            format: .png,
            originalFormat: .png,
            size: .init(
                width: outputPortraitWidth,
                height: outputPortraitHeight
            ),
            color: .systemOrange
        )
    ]

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
        let url = makePreviewFileURL(
            filename: filename,
            image: previewImage,
            format: format
        )

        return .init(
            sourceURL: url,
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
        color: UIColor
    ) -> ProcessedBatchImage {
        let previewImage = makePreviewImage(
            size: size,
            color: color
        )
        let url = makePreviewFileURL(
            filename: filename,
            image: previewImage,
            format: format
        )

        return .init(
            sourceID: .init(),
            outputURL: url,
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
        color: UIColor
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true

        return UIGraphicsImageRenderer(
            size: size,
            format: format
        ).image { context in
            color.setFill()
            context.fill(
                CGRect(
                    origin: .zero,
                    size: size
                )
            )
        }
    }

    static func makePreviewFileURL(
        filename: String,
        image: UIImage,
        format: ImageFileFormat
    ) -> URL {
        let url = temporaryDirectory.appendingPathComponent(filename)
        let data: Data? = switch format {
        case .png:
            image.pngData()
        case .jpeg, .heic, .other:
            image.jpegData(compressionQuality: 1)
        }

        if let data {
            try? data.write(
                to: url,
                options: .atomic
            )
        }

        return url
    }
}

private extension BatchImageHomeModel {
    static func previewImported() -> BatchImageHomeModel {
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )
        model.importedImages = ContentViewPreviewFactory.importedImages
        model.setReferencePixelsText("1080")
        return model
    }

    static func previewProcessed() -> BatchImageHomeModel {
        let model = previewImported()
        model.resultModel = .init(
            outcome: .init(
                processedImages: ContentViewPreviewFactory.processedImages,
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )
        return model
    }
}
