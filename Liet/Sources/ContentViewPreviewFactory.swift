import LietLibrary
import SwiftUI

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
