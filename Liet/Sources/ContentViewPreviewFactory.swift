import LietLibrary
import SwiftUI

#Preview("Chooser") {
    ContentView()
}

#Preview("Resize Imported") {
    ContentView(
        resizeModel: .previewImported(),
        selectedFeature: .resizeImages,
        preferredCompactColumn: .detail
    )
}

#Preview("Resize Result") {
    ContentView(
        resizeModel: .previewProcessed(),
        selectedFeature: .resizeImages,
        preferredCompactColumn: .detail
    )
}

#Preview("Background Imported") {
    ContentView(
        backgroundRemovalModel: .previewImported(),
        selectedFeature: .removeBackground,
        preferredCompactColumn: .detail
    )
}

#Preview("Background Result") {
    ContentView(
        backgroundRemovalModel: .previewProcessed(),
        selectedFeature: .removeBackground,
        preferredCompactColumn: .detail
    )
}

#Preview(
    "iPad Resize Imported",
    traits: .fixedLayout(
        width: ContentViewPreviewFactory.iPadPreviewWidth,
        height: ContentViewPreviewFactory.iPadPreviewHeight
    )
) {
    ContentView(
        resizeModel: .previewImported(),
        selectedFeature: .resizeImages
    )
}

#Preview(
    "iPad Background Result",
    traits: .fixedLayout(
        width: ContentViewPreviewFactory.iPadPreviewWidth,
        height: ContentViewPreviewFactory.iPadPreviewHeight
    )
) {
    ContentView(
        backgroundRemovalModel: .previewProcessed(),
        selectedFeature: .removeBackground
    )
}

private enum ContentViewPreviewFactory {
    static let iPadPreviewWidth = 1_194.0
    static let iPadPreviewHeight = 834.0
}

private extension BatchImageHomeModel {
    static func previewImported() -> BatchImageHomeModel {
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )
        model.importedImages = BatchImagePreviewFixture.importedImages
        model.setReferencePixelsText("1080")
        return model
    }

    static func previewProcessed() -> BatchImageHomeModel {
        let model = previewImported()
        model.resultModel = .init(
            outcome: .init(
                processedImages: BatchImagePreviewFixture.processedImages,
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )
        return model
    }
}

private extension BatchBackgroundRemovalHomeModel {
    static func previewImported() -> BatchBackgroundRemovalHomeModel {
        let model: BatchBackgroundRemovalHomeModel = .init(
            settingsStore: .inMemory()
        )
        model.importedImages = BatchImagePreviewFixture.importedImages
        return model
    }

    static func previewProcessed() -> BatchBackgroundRemovalHomeModel {
        let model = previewImported()
        model.resultModel = .init(
            outcome: .init(
                processedImages: BatchImagePreviewFixture.backgroundRemovedImages,
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )
        return model
    }
}
