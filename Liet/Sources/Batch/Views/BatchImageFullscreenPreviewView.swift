import SwiftUI
import UIKit

struct BatchImageFullscreenPreviewView: View {
    private enum Layout {
        static let closeButtonImageSize = 22.0
        static let closeButtonPadding = 10.0
        static let closeButtonBackgroundOpacity = 0.5
        static let closeButtonTopPadding = 12.0
        static let contentHorizontalPadding = 16.0
        static let contentVerticalSpacing = 16.0
        static let detailSpacing = 4.0
        static let metadataLineLimit = 2
        static let maximumZoomScale = 4.0
        static let metadataBottomPadding = 20.0
        static let metadataHorizontalPadding = 20.0
        static let secondaryTextOpacity = 0.72
    }

    private enum PreviewPhase {
        case loading
        case loaded(UIImage)
        case failed
    }

    @Environment(\.dismiss)
    private var dismiss

    let item: BatchImagePreviewItem

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
                spacing: Layout.contentVerticalSpacing
            ) {
                closeButtonRow()
                previewContent()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                metadataView()
            }
            .padding(.horizontal, Layout.contentHorizontalPadding)
            .padding(.bottom, Layout.metadataBottomPadding)
        }
        .task(id: item.id) {
            await loadPreview()
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
                    .font(.system(size: Layout.closeButtonImageSize, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(Layout.closeButtonPadding)
                    .background(
                        Circle()
                            .fill(.black.opacity(Layout.closeButtonBackgroundOpacity))
                    )
            }
            .padding(.top, Layout.closeButtonTopPadding)
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
                maximumZoomScale: Layout.maximumZoomScale
            ) {
                dismiss()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed:
            VStack(
                spacing: Layout.detailSpacing
            ) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                Text("Couldn't load the image preview.")
                    .font(.headline)
                Text("Close this viewer and try again.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(Layout.secondaryTextOpacity))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    func metadataView() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.detailSpacing
        ) {
            Text(item.displayName)
                .font(.headline)
                .lineLimit(Layout.metadataLineLimit)

            Text(item.detailText)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(Layout.secondaryTextOpacity))
                .lineLimit(Layout.metadataLineLimit)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Layout.metadataHorizontalPadding)
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
