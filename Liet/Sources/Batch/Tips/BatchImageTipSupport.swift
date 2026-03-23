import Foundation
import LietLibrary
import TipKit

enum BatchImageTipSupport {
    struct DonationSnapshot {
        let importCount: Int
        let processCount: Int
        let saveToFilesCount: Int
        let saveToPhotosCount: Int
    }

    struct ProgressSnapshot {
        let importCompleted: Bool
        let processCompleted: Bool
        let saveToFilesCompleted: Bool
        let saveToPhotosCompleted: Bool
    }

    nonisolated static let datastoreGroupIdentifier = AppGroup.id

    nonisolated static let didImportImages = Tips.Event(id: "batch.didImportImages")
    nonisolated static let didProcessImages = Tips.Event(id: "batch.didProcessImages")
    nonisolated static let didSaveToFiles = Tips.Event(id: "batch.didSaveToFiles")
    nonisolated static let didSaveToPhotos = Tips.Event(id: "batch.didSaveToPhotos")

    nonisolated(unsafe) private static var isConfigured = false
}

extension BatchImageTipSupport {
    nonisolated static func configureIfNeeded() {
        do {
            try configureIfNeededThrowing()
        } catch {
            assertionFailure("Failed to configure TipKit: \(error.localizedDescription)")
        }
    }

    nonisolated static func configureIfNeededThrowing() throws {
        guard !isConfigured else {
            return
        }

        try Tips.configure([
            .datastoreLocation(
                .groupContainer(identifier: datastoreGroupIdentifier)
            ),
            .displayFrequency(.immediate)
        ])
        isConfigured = true
    }

    static func resetTips() {
        SelectImagesTip.hasCompletedImportStep = false
        RunProcessingTip.hasCompletedProcessStep = false
        SaveDestinationTip.hasSavedToFiles = false
        SaveDestinationTip.hasSavedToPhotos = false
    }

    static func donateImportSuccess() {
        SelectImagesTip.hasCompletedImportStep = true
        didImportImages.sendDonation()
    }

    static func donateProcessSuccess() {
        RunProcessingTip.hasCompletedProcessStep = true
        didProcessImages.sendDonation()
    }

    static func donateSaveToFilesSuccess() {
        SaveDestinationTip.hasSavedToFiles = true
        didSaveToFiles.sendDonation()
    }

    static func donateSaveToPhotosSuccess() {
        SaveDestinationTip.hasSavedToPhotos = true
        didSaveToPhotos.sendDonation()
    }

    nonisolated static func donationSnapshot() -> DonationSnapshot {
        .init(
            importCount: didImportImages.donations.count,
            processCount: didProcessImages.donations.count,
            saveToFilesCount: didSaveToFiles.donations.count,
            saveToPhotosCount: didSaveToPhotos.donations.count
        )
    }

    static func progressSnapshot() -> ProgressSnapshot {
        .init(
            importCompleted: SelectImagesTip.hasCompletedImportStep,
            processCompleted: RunProcessingTip.hasCompletedProcessStep,
            saveToFilesCompleted: SaveDestinationTip.hasSavedToFiles,
            saveToPhotosCompleted: SaveDestinationTip.hasSavedToPhotos
        )
    }
}
