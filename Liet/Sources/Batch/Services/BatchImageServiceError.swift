import Foundation

enum BatchImageServiceError: Error {
    case failedToCreateArchive
    case failedToLoadImageData
    case failedToCreateImageSource
    case failedToReadImageProperties
    case failedToCreateThumbnail
    case failedToEncodeImage
    case failedToRemoveBackground
    case photoLibraryPermissionDenied
    case photoLibrarySaveFailed
}
