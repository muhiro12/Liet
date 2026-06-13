import PhotosUI
import SwiftUI

struct BatchImageImportInteractionModifier: ViewModifier {
    @Binding var selectedItems: [PhotosPickerItem]
    @Binding var isPresentingFileImporter: Bool
    @Binding var suppressesSelectedItemsDidChange: Bool

    let errorPresented: Binding<Bool>
    let alertTitle: () -> Text?
    let alertMessage: () -> Text?
    let dismissAlert: () -> Void
    let importPhotos: ([PhotosPickerItem]) async -> Void
    let importFiles: ([URL]) -> Void
    let handleImportFailure: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: selectedItems) { _, newValue in
                if suppressesSelectedItemsDidChange {
                    suppressesSelectedItemsDidChange = false
                    return
                }

                Task {
                    await importPhotos(newValue)
                }
            }
            .fileImporter(
                isPresented: $isPresentingFileImporter,
                allowedContentTypes: PhotoImportService.supportedImportContentTypes,
                allowsMultipleSelection: true
            ) { result in
                handleFileImportResult(result)
            } onCancellation: {
                // Keep the current selection unchanged when the picker is dismissed.
            }
            .alert(
                alertTitle() ?? Text("Action Failed"),
                isPresented: errorPresented
            ) {
                Button("OK", role: .cancel) {
                    dismissAlert()
                }
            } message: {
                if let alertMessage = alertMessage() {
                    alertMessage
                }
            }
    }
}

private extension BatchImageImportInteractionModifier {
    func handleFileImportResult(
        _ result: Result<[URL], any Error>
    ) {
        switch result {
        case let .success(fileURLs):
            guard !fileURLs.isEmpty else {
                return
            }

            if !selectedItems.isEmpty {
                suppressesSelectedItemsDidChange = true
                selectedItems = []
            }

            Task {
                importFiles(fileURLs)
            }
        case .failure:
            handleImportFailure()
        }
    }
}
