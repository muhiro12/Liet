import Foundation
import ImageIO
import OSLog
import UIKit

extension PhotoImportService {
    enum TransferredFileImportPhase: String {
        case loadTransferredFile
        case inspectTransferredFile
        case readTransferredFileProperties
        case copyTransferredFile
        case loadCopiedPreview
    }

    struct TransferredFileImportFailure: Error {
        let phase: TransferredFileImportPhase
        let underlyingError: Error
    }

    nonisolated static let logger = Logger(
        subsystem: "Liet",
        category: "PhotoImportService"
    )

    nonisolated static func importImage(
        from transferredFileURL: URL,
        supportedTypeIdentifiers: [String],
        selectionIndex: Int,
        into directoryURL: URL,
        resolvedOriginalFilename: String?
    ) throws -> ImportedBatchImage {
        let imageSource = try transferredImageSource(
            from: transferredFileURL
        )
        let pixelSize = try transferredPixelSize(
            from: imageSource
        )
        let originalFormat = ImageIOImageSupport.detectedFormat(
            for: imageSource,
            supportedTypeIdentifiers: supportedTypeIdentifiers
        )
        let sourceURL = directoryURL.appendingPathComponent(
            importedFilename(
                for: originalFormat,
                selectionIndex: selectionIndex
            )
        )
        try copyTransferredFile(
            from: transferredFileURL,
            to: sourceURL
        )
        let previewImage = try transferredPreviewImage(
            from: sourceURL
        )

        return .init(
            sourceURL: sourceURL,
            originalFilename: resolvedOriginalFilename ?? originalFilename(from: transferredFileURL),
            originalFormat: originalFormat,
            pixelSize: pixelSize,
            previewImage: previewImage,
            selectionIndex: selectionIndex
        )
    }

    nonisolated static func transferredImageSource(
        from transferredFileURL: URL
    ) throws -> CGImageSource {
        do {
            return try ImageIOImageSupport.imageSource(
                url: transferredFileURL
            )
        } catch {
            throw transferredFileImportFailure(
                phase: .inspectTransferredFile,
                error: error
            )
        }
    }

    nonisolated static func transferredPixelSize(
        from imageSource: CGImageSource
    ) throws -> CGSize {
        do {
            return try ImageIOImageSupport.pixelSize(from: imageSource)
        } catch {
            throw transferredFileImportFailure(
                phase: .readTransferredFileProperties,
                error: error
            )
        }
    }

    nonisolated static func copyTransferredFile(
        from transferredFileURL: URL,
        to sourceURL: URL
    ) throws {
        do {
            try FileManager.default.copyItem(
                at: transferredFileURL,
                to: sourceURL
            )
        } catch {
            throw transferredFileImportFailure(
                phase: .copyTransferredFile,
                error: error
            )
        }
    }

    nonisolated static func transferredPreviewImage(
        from sourceURL: URL
    ) throws -> UIImage {
        do {
            return try ImageIOImageSupport.previewImage(from: sourceURL)
        } catch {
            throw transferredFileImportFailure(
                phase: .loadCopiedPreview,
                error: error
            )
        }
    }

    nonisolated static func transferredFileImportFailure(
        phase: TransferredFileImportPhase,
        error: Error
    ) -> TransferredFileImportFailure {
        .init(
            phase: phase,
            underlyingError: error
        )
    }

    nonisolated static func logTransferredFileFallback(
        selectionIndex: Int,
        error: Error
    ) {
        let resolvedFailure = resolvedTransferredFileImportFailure(
            error: error,
            fallbackPhase: .loadTransferredFile
        )

        logTransferredFileFallback(
            selectionIndex: selectionIndex,
            failure: resolvedFailure
        )
    }

    nonisolated static func logTransferredFileFallback(
        selectionIndex: Int,
        phase: TransferredFileImportPhase,
        error: Error
    ) {
        let resolvedFailure = resolvedTransferredFileImportFailure(
            error: error,
            fallbackPhase: phase
        )

        logTransferredFileFallback(
            selectionIndex: selectionIndex,
            failure: resolvedFailure
        )
    }

    nonisolated static func resolvedTransferredFileImportFailure(
        error: Error,
        fallbackPhase: TransferredFileImportPhase
    ) -> TransferredFileImportFailure {
        if let transferredFileImportFailure = error as? TransferredFileImportFailure {
            return transferredFileImportFailure
        }

        return .init(
            phase: fallbackPhase,
            underlyingError: error
        )
    }

    nonisolated static func logTransferredFileFallback(
        selectionIndex: Int,
        failure: TransferredFileImportFailure
    ) {
        let message = String(
            describing: failure.underlyingError
        )

        logger.notice(
            """
            Falling back to data import for selection \(selectionIndex, privacy: .public) \
            at \(failure.phase.rawValue, privacy: .public): \(message, privacy: .private)
            """
        )
    }
}
