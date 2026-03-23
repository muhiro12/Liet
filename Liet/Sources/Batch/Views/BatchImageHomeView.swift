import LietLibrary
import PhotosUI
import SwiftUI

struct BatchImageHomeView: View {
    private enum Layout {
        static let contentPadding = 20.0
        static let contentSpacing = 24.0
        static let cardSpacing = 16.0
        static let gridSpacing = 12.0
        static let thumbnailColumnMinimum = 110.0
        static let controlSpacing = 12.0
    }

    @Bindable var model: BatchImageHomeModel
    @Binding var selectedItems: [PhotosPickerItem]

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
                importSection()
                settingsSection()
                actionSection()
            }
            .padding(Layout.contentPadding)
        }
        .navigationTitle("Liet")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: selectedItems) { _, newValue in
            Task {
                await model.importPhotos(from: newValue)
            }
        }
        .alert(
            "Error",
            isPresented: errorPresented
        ) {
            Button("OK", role: .cancel) {
                model.errorMessage = nil
            }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}

private extension BatchImageHomeView {
    var errorPresented: Binding<Bool> {
        Binding(
            get: {
                model.errorMessage != nil
            },
            set: { isPresented in
                if !isPresented {
                    model.errorMessage = nil
                }
            }
        )
    }

    func importSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            VStack(
                alignment: .leading,
                spacing: Layout.controlSpacing
            ) {
                Text("Select images")
                    .font(.title2.weight(.semibold))
                Text("Choose multiple photos, then apply one resize and compression setting to all of them.")
                    .foregroundStyle(.secondary)

                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: nil,
                    matching: .images,
                    preferredItemEncoding: .current
                ) {
                    Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                HStack {
                    Text(model.selectedImageCountText)
                        .font(.subheadline.weight(.medium))

                    Spacer()

                    if !model.importedImages.isEmpty {
                        Button("Clear") {
                            selectedItems = []
                            model.clearSelection()
                        }
                    }
                }

                if model.isImporting {
                    ProgressView("Loading images...")
                }

                if let importMessage = model.importMessage {
                    Text(importMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if !model.importedImages.isEmpty {
                LazyVGrid(
                    columns: columns,
                    alignment: .leading,
                    spacing: Layout.gridSpacing
                ) {
                    ForEach(model.importedImages) { image in
                        ImportedBatchImageTile(image: image)
                    }
                }
            }
        }
    }

    func settingsSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            Text("Settings")
                .font(.title3.weight(.semibold))

            VStack(
                alignment: .leading,
                spacing: Layout.controlSpacing
            ) {
                Text("Long edge (px)")
                    .font(.subheadline.weight(.medium))

                TextField("1920", text: $model.resizeLongEdgeText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                Text("Smaller images keep their original size.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(
                alignment: .leading,
                spacing: Layout.controlSpacing
            ) {
                Text("Compression")
                    .font(.subheadline.weight(.medium))

                Picker("Compression", selection: $model.compression) {
                    Text("High")
                        .tag(BatchImageCompression.high)
                    Text("Medium")
                        .tag(BatchImageCompression.medium)
                    Text("Low")
                        .tag(BatchImageCompression.low)
                }
                .pickerStyle(.segmented)

                Text("PNG keeps its format and ignores the compression quality setting.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    func actionSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Button {
                Task {
                    await model.processImages()
                }
            } label: {
                if model.isProcessing {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Process Images")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!model.canProcess)

            Text("Processed images are always written as new files.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
