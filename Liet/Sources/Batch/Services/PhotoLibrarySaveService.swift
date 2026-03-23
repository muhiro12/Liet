import Foundation
import Photos

enum PhotoLibrarySaveService {
    nonisolated static func save(
        _ images: [ProcessedBatchImage]
    ) async throws {
        guard !images.isEmpty else {
            return
        }

        let authorizationStatus = await authorizationStatus()

        guard authorizationStatus == .authorized ||
                authorizationStatus == .limited else {
            throw BatchImageServiceError.photoLibraryPermissionDenied
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                for image in images {
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(
                        with: .photo,
                        fileURL: image.outputURL,
                        options: nil
                    )
                }
            }, completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                if success {
                    continuation.resume()
                    return
                }

                continuation.resume(
                    throwing: BatchImageServiceError.photoLibrarySaveFailed
                )
            })
        }
    }
}

private extension PhotoLibrarySaveService {
    nonisolated static func authorizationStatus() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }
}
