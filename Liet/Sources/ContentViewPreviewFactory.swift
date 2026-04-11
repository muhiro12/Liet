import LietLibrary
import MHPlatform
import SwiftUI

#Preview("Chooser") {
    ContentView()
        .mhAppRuntimeEnvironment(ContentViewPreviewFactory.previewRuntime)
}

#Preview("Resize Imported") {
    ContentView(
        resizeModel: .previewImported(),
        selectedFeature: .resizeImages,
        preferredCompactColumn: .detail
    )
    .mhAppRuntimeEnvironment(ContentViewPreviewFactory.previewRuntime)
}

#Preview("Resize Result") {
    ContentView(
        resizeModel: .previewProcessed(),
        selectedFeature: .resizeImages,
        preferredCompactColumn: .detail
    )
    .mhAppRuntimeEnvironment(ContentViewPreviewFactory.previewRuntime)
}

#Preview("Background Imported") {
    ContentView(
        backgroundRemovalModel: .previewImported(),
        selectedFeature: .removeBackground,
        preferredCompactColumn: .detail
    )
    .mhAppRuntimeEnvironment(ContentViewPreviewFactory.previewRuntime)
}

#Preview("Background Result") {
    ContentView(
        backgroundRemovalModel: .previewProcessed(),
        selectedFeature: .removeBackground,
        preferredCompactColumn: .detail
    )
    .mhAppRuntimeEnvironment(ContentViewPreviewFactory.previewRuntime)
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
    .mhAppRuntimeEnvironment(ContentViewPreviewFactory.previewRuntime)
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
    .mhAppRuntimeEnvironment(ContentViewPreviewFactory.previewRuntime)
}

enum ContentViewPreviewFactory {
    static let iPadPreviewWidth = 1_194.0
    static let iPadPreviewHeight = 834.0

    @MainActor static var previewRuntime: MHAppRuntime {
        .init(
            runtimeOnly: .init(
                nativeAdUnitID: nil,
                preferencesDefaults: .suite(AppGroup.id),
                showsLicenses: false
            )
        )
    }
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
