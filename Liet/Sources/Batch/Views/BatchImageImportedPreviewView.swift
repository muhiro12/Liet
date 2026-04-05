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
    let summaryText: Text?
    let projectedPixelSizeResolver: ((ImportedBatchImage) -> CGSize?)?
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
    var selectionTitle: Text {
        if importedImages.count == 1 {
            Text("1 image selected")
        } else {
            Text("\(importedImages.count) images selected")
        }
    }

    func header() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.headerSpacing
        ) {
            titleView()

            if let summaryText {
                BatchStatusChip(
                    text: summaryText,
                    systemImage: "arrow.up.left.and.arrow.down.right",
                    tone: .accent
                )
            }
        }
    }

    @ViewBuilder
    func titleView() -> some View {
        let title = selectionTitle
            .font(.title2.weight(.semibold))

        if summaryText == nil,
           projectedPixelSizeResolver == nil {
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
        projectedPixelSizeResolver?(image)
    }
}
