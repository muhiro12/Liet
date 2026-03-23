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
            var failedToCreateAsset = false
            PHPhotoLibrary.shared().performChanges({
                failedToCreateAsset = !createAssetRequests(for: images)
            }, completionHandler: { success, error in
                resumeSave(
                    continuation: continuation,
                    success: success,
                    error: error,
                    failedToCreateAsset: failedToCreateAsset
                )
            })
        }
    }
}

private extension PhotoLibrarySaveService {
    nonisolated static func createAssetRequests(
        for images: [ProcessedBatchImage]
    ) -> Bool {
        for image in images {
            guard PHAssetChangeRequest.creationRequestForAssetFromImage(
                atFileURL: image.outputURL
            ) != nil else {
                return false
            }
        }

        return true
    }

    nonisolated static func resumeSave(
        continuation: CheckedContinuation<Void, Error>,
        success: Bool,
        error: (any Error)?,
        failedToCreateAsset: Bool
    ) {
        if let error {
            continuation.resume(throwing: error)
            return
        }

        if failedToCreateAsset {
            continuation.resume(
                throwing: BatchImageServiceError.photoLibrarySaveFailed
            )
            return
        }

        if success {
            continuation.resume()
            return
        }

        continuation.resume(
            throwing: BatchImageServiceError.photoLibrarySaveFailed
        )
    }

    nonisolated static func authorizationStatus() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }
}
