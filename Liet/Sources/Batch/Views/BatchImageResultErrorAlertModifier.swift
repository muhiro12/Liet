import SwiftUI

struct BatchImageResultErrorAlertModifier: ViewModifier {
    @Bindable var model: BatchImageResultModel

    func body(content: Content) -> some View {
        content.alert(
            "Error",
            isPresented: errorPresented
        ) {
            Button("OK", role: .cancel) {
                model.activeError = nil
            }
        } message: {
            if let activeError = model.activeError {
                errorText(for: activeError)
            }
        }
    }
}

extension View {
    func batchImageResultErrorAlert(
        model: BatchImageResultModel
    ) -> some View {
        modifier(
            BatchImageResultErrorAlertModifier(model: model)
        )
    }
}

private extension BatchImageResultErrorAlertModifier {
    var errorPresented: Binding<Bool> {
        Binding(
            get: {
                model.activeError != nil
            },
            set: { isPresented in
                if !isPresented {
                    model.activeError = nil
                }
            }
        )
    }

    func errorText(
        for error: any Error
    ) -> Text {
        if let batchError = error as? BatchImageServiceError {
            return batchServiceErrorText(for: batchError)
        }

        return Text(error.localizedDescription)
    }

    func batchServiceErrorText(
        for error: BatchImageServiceError
    ) -> Text {
        switch error {
        case .failedToCreateArchive:
            Text("Couldn't create the ZIP archive.")
        case .failedToCreateExportFolder:
            Text("Couldn't create the export folder.")
        case .failedToLoadImageData:
            Text("Couldn't load one of the selected images.")
        case .failedToCreateImageSource:
            Text("Couldn't read one of the selected images.")
        case .failedToReadImageProperties:
            Text("Couldn't inspect one of the selected images.")
        case .failedToCreateThumbnail:
            Text("Couldn't generate an image preview.")
        case .failedToEncodeImage:
            Text("Couldn't write one of the processed images.")
        case .failedToRemoveBackground:
            Text("Couldn't remove the background from one of the images.")
        case .photoLibraryPermissionDenied:
            Text("Photo Library access is required to save images.")
        case .photoLibrarySaveFailed:
            Text("Couldn't save the processed images to Photos.")
        }
    }
}
