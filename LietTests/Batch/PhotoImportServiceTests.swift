import CoreGraphics
import Foundation
@testable import Liet
import LietLibrary
import Testing
import UIKit

struct PhotoImportServiceTests {
    private enum Metrics {
        static let selectionIndex = 1
        static let sourceSize = CGSize(
            width: 640,
            height: 480
        )
    }

    @Test
    func original_filename_uses_transferred_file_basename_when_available() {
        let transferredFileURL = URL(fileURLWithPath: "/tmp/IMG_1234.HEIC")

        #expect(
            PhotoImportService.originalFilename(
                from: transferredFileURL
            ) == "IMG_1234.HEIC"
        )
    }

    @Test
    func original_filename_falls_back_to_nil_when_missing() {
        #expect(
            PhotoImportService.originalFilename(
                from: nil
            ) == nil
        )
    }

    @Test
    func import_image_falls_back_to_data_when_transferred_file_import_fails() async throws {
        let importDirectory = try makeImportDirectory()
        let image = BatchImageTestFactory.makeUIImage(
            size: Metrics.sourceSize
        )
        guard let data = image.jpegData(
            compressionQuality: 1
        ) else {
            throw BatchImageTestFactory.Failure.failedToCreateImageData
        }

        let transferredFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ImageFileFormat.jpeg.filenameExtension)

        let importedImage = try await PhotoImportService.importImage(
            supportedTypeIdentifiers: [ImageFileFormat.jpeg.sourceTypeIdentifier],
            selectionIndex: Metrics.selectionIndex,
            into: importDirectory,
            loadTransferredFileURL: { transferredFileURL },
            loadData: { data }
        )

        #expect(importedImage.originalFilename == nil)
        #expect(importedImage.originalFormat == .jpeg)
        #expect(importedImage.pixelSize == Metrics.sourceSize)
        #expect(importedImage.selectionIndex == Metrics.selectionIndex)
        #expect(
            FileManager.default.fileExists(
                atPath: importedImage.sourceURL.path
            )
        )
    }

    @Test
    func import_image_preserves_original_filename_when_transferred_file_import_succeeds() async throws {
        let importDirectory = try makeImportDirectory()
        let transferredFileURL = try BatchImageTestFactory.writeImageData(
            for: BatchImageTestFactory.makeUIImage(
                size: Metrics.sourceSize
            ),
            format: .jpeg,
            filename: "IMG_1234.JPG"
        )
        var didLoadData = false

        let importedImage = try await PhotoImportService.importImage(
            supportedTypeIdentifiers: [ImageFileFormat.jpeg.sourceTypeIdentifier],
            selectionIndex: Metrics.selectionIndex,
            into: importDirectory,
            loadTransferredFileURL: { transferredFileURL },
            loadData: {
                didLoadData = true
                return nil
            }
        )

        #expect(importedImage.originalFilename == "IMG_1234.JPG")
        #expect(importedImage.originalFormat == .jpeg)
        #expect(importedImage.pixelSize == Metrics.sourceSize)
        #expect(didLoadData == false)
    }

    @Test
    func import_image_fails_only_after_transferred_file_and_data_loading_fail() async throws {
        let importDirectory = try makeImportDirectory()
        let transferredFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ImageFileFormat.jpeg.filenameExtension)

        do {
            _ = try await PhotoImportService.importImage(
                supportedTypeIdentifiers: [ImageFileFormat.jpeg.sourceTypeIdentifier],
                selectionIndex: Metrics.selectionIndex,
                into: importDirectory,
                loadTransferredFileURL: { transferredFileURL },
                loadData: { nil }
            )
            #expect(false)
        } catch let error as BatchImageServiceError {
            #expect(error == .failedToLoadImageData)
        } catch {
            #expect(false)
        }
    }

    private func makeImportDirectory() throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "LietPhotoImportTests-\(UUID().uuidString)",
                isDirectory: true
            )

        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        return directoryURL
    }
}
