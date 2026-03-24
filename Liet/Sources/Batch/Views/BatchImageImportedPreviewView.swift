import LietLibrary
import SwiftUI

struct BatchImageImportedPreviewView: View {
    private enum Layout {
        static let contentPadding = 20.0
        static let contentSpacing = 24.0
        static let gridSpacing = 12.0
        static let thumbnailColumnMinimum = 130.0
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let importedImages: [ImportedBatchImage]
    let settings: BatchImageSettings?
    let backToSettings: (() -> Void)?

    private let columns = [
        GridItem(
            .adaptive(minimum: Layout.thumbnailColumnMinimum),
            spacing: Layout.gridSpacing
        )
    ]

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: Layout.contentSpacing
            ) {
                header()

                LazyVGrid(
                    columns: columns,
                    alignment: .leading,
                    spacing: Layout.gridSpacing
                ) {
                    ForEach(importedImages) { image in
                        ImportedBatchImageTile(
                            image: image,
                            projectedPixelSize: projectedPixelSize(for: image)
                        )
                    }
                }
            }
            .padding(Layout.contentPadding)
        }
        .navigationTitle("Selection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let backToSettings,
               horizontalSizeClass == .compact {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back to Settings") {
                        backToSettings()
                    }
                }
            }
        }
    }
}

private extension BatchImageImportedPreviewView {
    func header() -> some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            Text(selectionTitle)
                .font(.title2.weight(.semibold))

            Text(headerDetailText)
                .foregroundStyle(.secondary)
        }
    }

    var selectionTitle: String {
        if importedImages.count == 1 {
            "1 image selected"
        } else {
            "\(importedImages.count) images selected"
        }
    }

    var headerDetailText: String {
        if let settings {
            return outputSummaryText(settings)
        }

        return "Choose an output size in the sidebar to preview each processed image size."
    }

    func projectedPixelSize(
        for image: ImportedBatchImage
    ) -> CGSize? {
        guard let settings else {
            return nil
        }

        return BatchImageProcessor.projectedPixelSize(
            for: image,
            settings: settings
        )
    }

    func outputSummaryText(
        _ settings: BatchImageSettings
    ) -> String {
        if let referenceDimension = settings.referenceDimension,
           let referencePixels = settings.referencePixels {
            let referenceLabel = switch referenceDimension {
            case .width:
                "Width"
            case .height:
                "Height"
            }

            return "\(referenceLabel) \(referencePixels) px with aspect ratio preserved."
        }

        guard let exactWidthPixels = settings.exactWidthPixels,
              let exactHeightPixels = settings.exactHeightPixels,
              let exactResizeStrategy = settings.exactResizeStrategy else {
            return "Review the imported images before running the batch."
        }

        let strategyLabel = switch exactResizeStrategy {
        case .stretch:
            "Stretch"
        case .contain:
            "Contain"
        case .coverCrop:
            "Crop"
        }

        return "Exact \(exactWidthPixels)×\(exactHeightPixels) using \(strategyLabel)."
    }
}
