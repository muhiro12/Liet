import Foundation

enum BatchImageServiceError: Error {
    case failedToLoadImageData
    case failedToCreateImageSource
    case failedToReadImageProperties
    case failedToCreateThumbnail
    case failedToEncodeImage
    case photoLibraryPermissionDenied
    case photoLibrarySaveFailed
}
