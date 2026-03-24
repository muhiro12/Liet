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
                        ImportedBatchImageTile(image: image)
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

            Text("Review the imported images before running the batch.")
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
}
