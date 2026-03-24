import CoreGraphics
import Foundation
@testable import Liet
import LietLibrary
import Testing

@MainActor
struct BatchImageHomeModelPersistenceTests {
    private enum Metrics {
        static let importedSelectionIndex = 1
        static let sourceSize = CGSize(width: 1_000, height: 500)
    }

    @Test
    func model_starts_from_last_used_settings() {
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory(
                initialValue: .init(
                    userPresetSettings: .init(
                        resizeMode: .aspectRatioPreserved,
                        referenceDimension: .width,
                        referencePixels: 2_048,
                        exactWidthPixels: 1_920,
                        exactHeightPixels: 1_080,
                        exactResizeStrategy: .stretch,
                        compression: .high
                    ),
                    lastUsedSettings: .init(
                        resizeMode: .exactSize,
                        referenceDimension: .height,
                        referencePixels: 720,
                        exactWidthPixels: 320,
                        exactHeightPixels: 180,
                        exactResizeStrategy: .coverCrop,
                        compression: .medium
                    )
                )
            )
        )

        #expect(model.settingsSource == .lastUsed)
        #expect(model.hasUserPresetSettings)
        #expect(model.keepsAspectRatio == false)
        #expect(model.resizeWidthText == "320")
        #expect(model.resizeHeightText == "180")
        #expect(model.exactResizeStrategy == .coverCrop)
        #expect(model.compression == .medium)
    }

    @Test
    func model_starts_without_a_user_preset_until_one_is_saved() {
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )

        #expect(model.settingsSource == .lastUsed)
        #expect(model.hasUserPresetSettings == false)
        #expect(model.canSaveCurrentAsUserPreset)

        model.applyUserPresetSettings()

        #expect(model.settingsSource == .lastUsed)
        #expect(model.keepsAspectRatio)
        #expect(model.referencePixelsText == "1920")
        #expect(model.compression == .off)
    }

    @Test
    func selecting_saved_sources_updates_current_settings() {
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory(
                initialValue: .init(
                    userPresetSettings: .init(
                        resizeMode: .exactSize,
                        referenceDimension: .height,
                        referencePixels: 640,
                        exactWidthPixels: 320,
                        exactHeightPixels: 180,
                        exactResizeStrategy: .coverCrop,
                        compression: .medium
                    ),
                    lastUsedSettings: .init(
                        resizeMode: .aspectRatioPreserved,
                        referenceDimension: .height,
                        referencePixels: 1_080,
                        exactWidthPixels: 1_920,
                        exactHeightPixels: 1_080,
                        exactResizeStrategy: .stretch,
                        compression: .high
                    )
                )
            )
        )

        #expect(model.settingsSource == .lastUsed)
        #expect(model.hasUserPresetSettings)
        #expect(model.referenceDimension == .height)
        #expect(model.referencePixelsText == "1080")
        #expect(model.keepsAspectRatio)
        #expect(model.compression == .high)

        model.applyUserPresetSettings()

        #expect(model.settingsSource == .userPreset)
        #expect(model.keepsAspectRatio == false)
        #expect(model.resizeWidthText == "320")
        #expect(model.resizeHeightText == "180")
        #expect(model.exactResizeStrategy == .coverCrop)
        #expect(model.compression == .medium)

        model.applyLastUsedSettings()

        #expect(model.settingsSource == .lastUsed)
        #expect(model.referenceDimension == .height)
        #expect(model.referencePixelsText == "1080")
        #expect(model.keepsAspectRatio)
        #expect(model.compression == .high)
    }

    @Test
    func saving_current_settings_as_user_preset_controls_the_saved_slot() {
        let settingsStore = BatchImageSettingsStore.inMemory()
        let firstModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        firstModel.setKeepsAspectRatio(false)
        firstModel.setResizeWidthText("320")
        firstModel.setResizeHeightText("180")
        firstModel.exactResizeStrategy = .coverCrop
        firstModel.compression = .medium
        firstModel.saveCurrentAsUserPreset()

        #expect(firstModel.settingsSource == .userPreset)
        #expect(firstModel.hasUserPresetSettings)

        let secondModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        #expect(secondModel.settingsSource == .lastUsed)
        #expect(secondModel.hasUserPresetSettings)
        #expect(secondModel.keepsAspectRatio)
        #expect(secondModel.compression == .off)

        secondModel.applyUserPresetSettings()

        #expect(secondModel.settingsSource == .userPreset)
        #expect(secondModel.keepsAspectRatio == false)
        #expect(secondModel.resizeWidthText == "320")
        #expect(secondModel.resizeHeightText == "180")
        #expect(secondModel.exactResizeStrategy == .coverCrop)
        #expect(secondModel.compression == .medium)
    }

    @Test
    func valid_changes_do_not_update_last_used_until_processing() {
        let settingsStore = BatchImageSettingsStore.inMemory()
        let firstModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        firstModel.setReferenceDimension(.height)
        firstModel.setReferencePixelsText("1080")
        firstModel.compression = .high

        let secondModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        #expect(secondModel.settingsSource == .lastUsed)
        #expect(secondModel.hasUserPresetSettings == false)
        #expect(secondModel.referenceDimension == .width)
        #expect(secondModel.referencePixelsText == "1920")
        #expect(secondModel.keepsAspectRatio)
        #expect(secondModel.compression == .off)
    }

    @Test
    func processing_updates_last_used_and_next_launch_state() throws {
        let settingsStore = BatchImageSettingsStore.inMemory()
        let firstModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        firstModel.setReferenceDimension(.height)
        firstModel.setReferencePixelsText("1080")
        firstModel.compression = .high
        firstModel.importedImages = [
            try BatchImageTestFactory.makeImportedImage(
                format: .jpeg,
                size: Metrics.sourceSize,
                originalFilename: "processed.jpg",
                selectionIndex: Metrics.importedSelectionIndex
            )
        ]

        firstModel.processImages()

        #expect(firstModel.resultModel != nil)
        #expect(firstModel.settingsSource == .lastUsed)
        #expect(firstModel.hasUserPresetSettings == false)

        let secondModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        #expect(secondModel.settingsSource == .lastUsed)
        #expect(secondModel.hasUserPresetSettings == false)
        #expect(secondModel.referenceDimension == .height)
        #expect(secondModel.referencePixelsText == "1080")
        #expect(secondModel.keepsAspectRatio)
        #expect(secondModel.compression == .high)
    }

    @Test
    func failed_processing_still_updates_last_used_settings() {
        let settingsStore = BatchImageSettingsStore.inMemory()
        let firstModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        firstModel.setKeepsAspectRatio(false)
        firstModel.setResizeWidthText("320")
        firstModel.setResizeHeightText("180")
        firstModel.exactResizeStrategy = .coverCrop
        firstModel.compression = .medium
        firstModel.importedImages = [
            BatchImageTestFactory.makeMissingImportedImage(
                format: .jpeg,
                originalFilename: "missing.jpg",
                selectionIndex: Metrics.importedSelectionIndex
            )
        ]

        firstModel.processImages()

        #expect(firstModel.resultModel == nil)
        #expect(firstModel.activeAlert == .processSelectionFailed)
        #expect(firstModel.settingsSource == .lastUsed)
        #expect(firstModel.hasUserPresetSettings == false)

        let secondModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        #expect(secondModel.settingsSource == .lastUsed)
        #expect(secondModel.hasUserPresetSettings == false)
        #expect(secondModel.keepsAspectRatio == false)
        #expect(secondModel.resizeWidthText == "320")
        #expect(secondModel.resizeHeightText == "180")
        #expect(secondModel.exactResizeStrategy == .coverCrop)
        #expect(secondModel.compression == .medium)
    }

    @Test
    func selecting_user_preset_does_not_overwrite_last_used_settings() {
        let settingsStore = BatchImageSettingsStore.inMemory(
            initialValue: .init(
                userPresetSettings: .init(
                    resizeMode: .exactSize,
                    referenceDimension: .height,
                    referencePixels: 720,
                    exactWidthPixels: 320,
                    exactHeightPixels: 180,
                    exactResizeStrategy: .coverCrop,
                    compression: .medium
                ),
                lastUsedSettings: .default
            )
        )
        let firstModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        firstModel.applyUserPresetSettings()

        let secondModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        #expect(secondModel.settingsSource == .lastUsed)
        #expect(secondModel.hasUserPresetSettings)
        #expect(secondModel.keepsAspectRatio)
        #expect(secondModel.compression == .off)

        secondModel.applyUserPresetSettings()

        #expect(secondModel.keepsAspectRatio == false)
        #expect(secondModel.resizeWidthText == "320")
        #expect(secondModel.resizeHeightText == "180")
        #expect(secondModel.exactResizeStrategy == .coverCrop)
        #expect(secondModel.compression == .medium)
    }
}
