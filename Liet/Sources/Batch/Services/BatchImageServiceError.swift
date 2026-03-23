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
        switch self {
        case .failedToLoadImageData:
            "Couldn't load one of the selected images."
        case .failedToCreateImageSource:
            "Couldn't read one of the selected images."
        case .failedToReadImageProperties:
            "Couldn't inspect one of the selected images."
        case .failedToCreateThumbnail:
            "Couldn't generate an image preview."
        case .failedToEncodeImage:
            "Couldn't write one of the processed images."
        case .photoLibraryPermissionDenied:
            "Photo Library access is required to save images."
        case .photoLibrarySaveFailed:
            "Couldn't save the processed images to Photos."
        }
    }
}
