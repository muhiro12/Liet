import SwiftUI
import UIKit

struct BatchImageFullscreenPreviewView: View {
    @Environment(\.dismiss)
    private var dismiss

    let item: BatchImagePreviewItem
    private let usesInjectedPreviewImage: Bool

    @State private var previewPhase: BatchImageFullscreenPreviewPhase = .loading

    var body: some View {
        ZStack {
            BatchImageFullscreenDismissBackground(dismissPreview: dismissPreview)

            VStack(
                spacing: BatchDesign.Fullscreen.contentVerticalSpacing
            ) {
                BatchImageFullscreenCloseButtonRow(dismissPreview: dismissPreview)
                BatchImageFullscreenPreviewContentView(
                    previewPhase: previewPhase,
                    imageAccessibilityLabel: item.displayName,
                    showsTransparencyBackground: item.showsTransparencyBackground,
                    dismissPreview: dismissPreview
                )
                BatchImageFullscreenMetadataView(
                    displayName: item.displayName,
                    detailText: item.detailText
                )
            }
            .padding(.horizontal, BatchDesign.Fullscreen.contentHorizontalPadding)
            .padding(.bottom, BatchDesign.Fullscreen.metadataBottomPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .statusBarHidden()
        .toolbar(.hidden, for: .navigationBar)
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
    func dismissPreview() {
        dismiss()
    }

    func loadPreview() async {
        previewPhase = .loading

        let item = item
        let loadedPhase: BatchImageFullscreenPreviewPhase = await withCheckedContinuation { continuation in
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
