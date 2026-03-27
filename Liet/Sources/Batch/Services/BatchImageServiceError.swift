import Foundation

enum BatchImageServiceError: Error {
    case failedToCreateArchive
    case failedToLoadImageData
    case failedToCreateImageSource
    case failedToReadImageProperties
    case failedToCreateThumbnail
    case failedToEncodeImage
    case photoLibraryPermissionDenied
    case photoLibrarySaveFailed
}
