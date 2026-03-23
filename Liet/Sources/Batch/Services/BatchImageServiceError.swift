import Foundation

enum BatchImageServiceError: LocalizedError {
    case failedToLoadImageData
    case failedToCreateImageSource
    case failedToReadImageProperties
    case failedToCreateThumbnail
    case failedToEncodeImage
    case photoLibraryPermissionDenied
    case photoLibrarySaveFailed
}

extension BatchImageServiceError {
    nonisolated var errorDescription: String? {
        BatchImageLocalization().serviceErrorMessage(self)
    }
}
