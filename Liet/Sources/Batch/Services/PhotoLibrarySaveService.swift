import Foundation
import Photos

enum PhotoLibrarySaveService {
    struct AssetResourceInput: Equatable {
        let resourceType: PHAssetResourceType
        let fileURL: URL
        let originalFilename: String
    }
}

extension PhotoLibrarySaveService {
    nonisolated static func save(
        _ inputs: [AssetResourceInput]
    ) async throws {
        guard !inputs.isEmpty else {
            return
        }

        let authorizationStatus = await authorizationStatus()

        guard authorizationStatus == .authorized ||
                authorizationStatus == .limited else {
            throw BatchImageServiceError.photoLibraryPermissionDenied
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                createAssetRequests(for: inputs)
            }, completionHandler: { success, error in
                resumeSave(
                    continuation: continuation,
                    success: success,
                    error: error
                )
            })
        }
    }

    nonisolated static func assetResourceInputs(
        for images: [ProcessedBatchImage]
    ) -> [AssetResourceInput] {
        images.map { image in
            .init(
                resourceType: .photo,
                fileURL: image.outputURL,
                originalFilename: image.outputFilename
            )
        }
    }
}

private extension PhotoLibrarySaveService {
    nonisolated static func createAssetRequests(
        for inputs: [AssetResourceInput]
    ) {
        for input in inputs {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(
                with: input.resourceType,
                fileURL: input.fileURL,
                options: resourceCreationOptions(for: input)
            )
        }
    }

    nonisolated static func resourceCreationOptions(
        for input: AssetResourceInput
    ) -> PHAssetResourceCreationOptions {
        let options = PHAssetResourceCreationOptions()
        options.originalFilename = input.originalFilename
        return options
    }

    nonisolated static func resumeSave(
        continuation: CheckedContinuation<Void, Error>,
        success: Bool,
        error: (any Error)?
    ) {
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
    }

    nonisolated static func authorizationStatus() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }
}
