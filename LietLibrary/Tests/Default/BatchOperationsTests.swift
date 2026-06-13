import CoreGraphics
import Foundation
@testable import LietLibrary
import Testing

struct BatchOperationsTests {
    @Test
    func processing_operations_make_surface_facing_plans() {
        let plan = BatchImageProcessingOperations.makePlan(
            for: .init(
                originalFormat: .heic,
                originalPixelSize: .init(width: 1_200, height: 800),
                selectionIndex: 1
            ),
            settings: .init(
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 600
                ),
                compression: .high,
                naming: .default
            ),
            heicEncoderAvailable: false
        )

        #expect(plan.outputFormat == .jpeg)
        #expect(plan.outputFilename == "IMG_001.jpeg")
        #expect(Int(plan.outputPixelSize.width) == 600)
        #expect(Int(plan.outputPixelSize.height) == 400)
        #expect(plan.usedJPEGFallback)
    }

    @Test
    func filename_operations_resolve_edited_duplicate_names() {
        let firstID = UUID()
        let secondID = UUID()
        let items: [BatchImageFilenameOperations.Item] = [
            .init(
                id: firstID,
                defaultStem: "IMG_001",
                outputFormat: .jpeg
            ),
            .init(
                id: secondID,
                defaultStem: "IMG_002",
                outputFormat: .jpeg
            )
        ]
        var operations: BatchImageFilenameOperations = .init()

        operations.setEditableFilenameStem(
            "Holiday.jpg",
            for: items[0]
        )
        operations.setEditableFilenameStem(
            "Holiday",
            for: items[1]
        )

        #expect(
            operations.resolvedFilenames(for: items) == [
                firstID: "Holiday.jpeg",
                secondID: "Holiday-2.jpeg"
            ]
        )
    }

    @Test
    func archive_operations_build_zip_data() throws {
        let archiveData = try BatchImageArchiveOperations.makeArchiveData(
            for: [
                .init(
                    filename: "processed.png",
                    data: Data([0x01, 0x02])
                )
            ]
        )
        let archive = try ZIPArchiveFixture(
            archiveData: archiveData
        )

        #expect(archive.entries.map(\.filename) == ["processed.png"])
        #expect(archive.entries.map(\.data) == [Data([0x01, 0x02])])
    }
}
