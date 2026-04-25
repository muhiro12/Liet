import SwiftUI
import UIKit

struct BatchImageFullscreenPreviewView: View {
    private enum PreviewPhase {
        case loading
        case loaded(UIImage)
        case failed
    }

    @Environment(\.dismiss)
    private var dismiss

    let item: BatchImagePreviewItem
    private let usesInjectedPreviewImage: Bool

    @State private var previewPhase: PreviewPhase = .loading

    var body: some View {
        ZStack {
            Button {
                dismiss()
            } label: {
                Color.black
                    .ignoresSafeArea()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close Preview")

            VStack(
                spacing: BatchDesign.Fullscreen.contentVerticalSpacing
            ) {
                closeButtonRow()
                previewContent()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                metadataView()
            }
            .padding(.horizontal, BatchDesign.Fullscreen.contentHorizontalPadding)
            .padding(.bottom, BatchDesign.Fullscreen.metadataBottomPadding)
        }
        .task(id: item.id) {
            guard !usesInjectedPreviewImage else {
                return
            }

            await loadPreview()
        }
    }
}

extension BatchImageFullscreenPreviewView {
    init(
        item: BatchImagePreviewItem,
        initialPreviewImage: UIImage? = nil
    ) {
        self.item = item
        usesInjectedPreviewImage = initialPreviewImage != nil

        if let initialPreviewImage {
            _previewPhase = State(
                initialValue: .loaded(initialPreviewImage)
            )
        } else {
            _previewPhase = State(
                initialValue: .loading
            )
        }
    }
}

private extension BatchImageFullscreenPreviewView {
    func closeButtonRow() -> some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: BatchDesign.Fullscreen.closeButtonImageSize, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(BatchDesign.Fullscreen.closeButtonPadding)
                    .background(
                        Circle()
                            .fill(.black.opacity(BatchDesign.Fullscreen.closeButtonBackgroundOpacity))
                    )
            }
            .padding(.top, BatchDesign.Fullscreen.closeButtonTopPadding)
            .accessibilityLabel("Close Preview")
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func previewContent() -> some View {
        switch previewPhase {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .loaded(image):
            BatchImageZoomableScrollView(
                image: image,
                maximumZoomScale: BatchDesign.Fullscreen.maximumZoomScale,
                showsTransparencyBackground: item.showsTransparencyBackground
            ) {
                dismiss()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed:
            VStack(
                spacing: BatchDesign.Fullscreen.detailSpacing
            ) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                Text("Couldn't load the image preview.")
                    .font(.headline)
                Text("Close this viewer and try again.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(BatchDesign.Fullscreen.secondaryTextOpacity))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    func metadataView() -> some View {
        VStack(
            alignment: .leading,
            spacing: BatchDesign.Fullscreen.detailSpacing
        ) {
            Text(item.displayName)
                .font(.headline)
                .lineLimit(BatchDesign.Fullscreen.metadataLineLimit)

            Text(item.detailText)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(BatchDesign.Fullscreen.secondaryTextOpacity))
                .lineLimit(BatchDesign.Fullscreen.metadataLineLimit)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, BatchDesign.Fullscreen.metadataHorizontalPadding)
    }

    func loadPreview() async {
        previewPhase = .loading

        let item = item
        let loadedPhase: PreviewPhase = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let image = try ImageIOImageSupport.fullScreenPreviewImage(
                        from: item.imageURL,
                        originalPixelSize: item.pixelSize
                    )
                    continuation.resume(returning: .loaded(image))
                } catch {
                    continuation.resume(returning: .failed)
                }
            }
        }

        guard !Task.isCancelled else {
            return
        }

        previewPhase = loadedPhase
    }
}

#Preview("Imported Fullscreen") {
    BatchImageFullscreenPreviewView(
        item: BatchImagePreviewFixture.importedPreviewItem,
        initialPreviewImage: BatchImagePreviewFixture.importedFullscreenPreviewImage
    )
}

#Preview("Processed Fullscreen") {
    BatchImageFullscreenPreviewView(
        item: BatchImagePreviewFixture.processedPreviewItem,
        initialPreviewImage: BatchImagePreviewFixture.processedFullscreenPreviewImage
    )
}

#Preview("Transparent Processed Fullscreen") {
    BatchImageFullscreenPreviewView(
        item: BatchImagePreviewFixture.transparentProcessedPreviewItem,
        initialPreviewImage: BatchImagePreviewFixture.transparentFullscreenPreviewImage
    )
}
