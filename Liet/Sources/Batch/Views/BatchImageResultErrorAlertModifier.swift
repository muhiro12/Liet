import SwiftUI

struct BatchImageResultErrorAlertModifier: ViewModifier {
    @Bindable var model: BatchImageResultModel

    func body(content: Content) -> some View {
        content.alert(
            alertTitle,
            isPresented: $model.isActiveErrorPresented
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
    var alertTitle: Text {
        guard let activeError = model.activeError else {
            return Text("Action Failed")
        }

        return errorTitle(for: activeError)
    }

    func errorTitle(
        for error: any Error
    ) -> Text {
        if let batchError = error as? BatchImageServiceError {
            return batchServiceErrorTitle(for: batchError)
        }

        return Text("Action Failed")
    }

    func errorText(
        for error: any Error
    ) -> Text {
        if let batchError = error as? BatchImageServiceError {
            return batchServiceErrorText(for: batchError)
        }

        return Text(error.localizedDescription)
    }

    func batchServiceErrorTitle(
        for error: BatchImageServiceError
    ) -> Text {
        switch error {
        case .failedToCreateArchive,
             .failedToCreateExportFolder,
             .failedToEncodeImage:
            Text("Export Failed")
        case .failedToLoadImageData,
             .failedToCreateImageSource,
             .failedToReadImageProperties,
             .failedToCreateThumbnail,
             .failedToRemoveBackground:
            Text("Processing Failed")
        case .photoLibraryPermissionDenied,
             .photoLibrarySaveFailed:
            Text("Save to Photos Failed")
        }
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
