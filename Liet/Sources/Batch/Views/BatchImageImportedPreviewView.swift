import LietLibrary
import SwiftUI
import TipKit

struct BatchImageImportedPreviewView: View {
    private enum Layout {
        static let contentPadding = 20.0
        static let contentSpacing = 24.0
        static let gridSpacing = 12.0
        static let headerSpacing = 8.0
        static let thumbnailColumnMinimum = 130.0
    }

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var activePreviewItem: BatchImagePreviewItem?

    let importedImages: [ImportedBatchImage]
    let settings: BatchImageSettings?
    let backToSettings: (() -> Void)?
    private let selectionPreviewTip = SelectionPreviewTip()

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
                            imageTapAction: {
                                activePreviewItem = .init(
                                    importedImage: image
                                )
                            },
                            projectedPixelSize: projectedPixelSize(for: image)
                        )
                    }
                }
            }
            .padding(Layout.contentPadding)
        }
        .fullScreenCover(item: $activePreviewItem) { item in
            BatchImageFullscreenPreviewView(
                item: item
            )
        }
        .navigationTitle("Selection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let backToSettings,
               horizontalSizeClass == .compact {
                ToolbarItem(placement: .topBarLeading) {
                    BatchToolbarIconButton(
                        systemImage: "sidebar.leading",
                        accessibilityLabel: "Back to Settings"
                    ) {
                        backToSettings()
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                BatchToolbarIconButton(
                    systemImage: "questionmark.circle",
                    accessibilityLabel: "Show Tips Again"
                ) {
                    BatchImageTipSupport.resetTips()
                }
            }
        }
    }
}

private extension BatchImageImportedPreviewView {
    var selectionTitle: String {
        if importedImages.count == 1 {
            "1 image selected"
        } else {
            "\(importedImages.count) images selected"
        }
    }

    var summaryText: String? {
        guard let settings else {
            return nil
        }

        return outputSummaryText(settings)
    }

    func header() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.headerSpacing
        ) {
            titleView()

            if let summaryText {
                BatchStatusChip(
                    text: Text(summaryText),
                    systemImage: "arrow.up.left.and.arrow.down.right",
                    tone: .accent
                )
            }
        }
    }

    @ViewBuilder
    func titleView() -> some View {
        let title = Text(selectionTitle)
            .font(.title2.weight(.semibold))

        if settings == nil {
            title.popoverTip(
                selectionPreviewTip,
                arrowEdge: .top
            )
        } else {
            title
        }
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
    ) -> String? {
        if let referenceDimension = settings.referenceDimension,
           let referencePixels = settings.referencePixels {
            let referenceLabel = switch referenceDimension {
            case .width:
                String(localized: "Width")
            case .height:
                String(localized: "Height")
            }

            return "\(referenceLabel) \(referencePixels) px • \(String(localized: "Keep ratio"))"
        }

        guard let exactWidthPixels = settings.exactWidthPixels,
              let exactHeightPixels = settings.exactHeightPixels,
              let exactResizeStrategy = settings.exactResizeStrategy else {
            return nil
        }

        let strategyLabel = switch exactResizeStrategy {
        case .stretch:
            String(localized: "Stretch")
        case .contain:
            String(localized: "Contain")
        case .coverCrop:
            String(localized: "Crop")
        }

        return "\(exactWidthPixels)×\(exactHeightPixels) • \(strategyLabel)"
    }
}
