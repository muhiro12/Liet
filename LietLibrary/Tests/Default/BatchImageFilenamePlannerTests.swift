@testable import LietLibrary
import Testing

struct BatchImageFilenamePlannerTests {
    @Test
    func blank_custom_stems_fall_back_to_default_output_names() {
        let firstItem = makeItem(defaultStem: "IMG_001")
        let secondItem = makeItem(defaultStem: "IMG_002")
        var planner: BatchImageFilenamePlanner = .init()

        planner.setEditableFilenameStem("", for: firstItem)
        planner.setEditableFilenameStem("shared.jpg", for: secondItem)

        #expect(
            planner.resolvedFilename(
                for: firstItem,
                within: [firstItem, secondItem]
            ) == "IMG_001.jpeg"
        )
        #expect(planner.editableFilenameStem(for: secondItem) == "shared")
        #expect(
            planner.resolvedFilename(
                for: secondItem,
                within: [firstItem, secondItem]
            ) == "shared.jpeg"
        )
    }

    @Test
    func duplicate_custom_stems_are_deduplicated_in_item_order() {
        let firstItem = makeItem(defaultStem: "IMG_001")
        let secondItem = makeItem(defaultStem: "IMG_002")
        var planner: BatchImageFilenamePlanner = .init()

        planner.setEditableFilenameStem("shared", for: firstItem)
        planner.setEditableFilenameStem("shared", for: secondItem)

        let resolvedFilenames = planner.resolvedFilenames(
            for: [firstItem, secondItem]
        )

        #expect(resolvedFilenames[firstItem.id] == "shared.jpeg")
        #expect(resolvedFilenames[secondItem.id] == "shared-2.jpeg")
    }

    @Test
    func custom_stems_strip_trailing_image_extensions_before_deduplication() {
        let firstItem = makeItem(defaultStem: "IMG_001")
        let secondItem = makeItem(defaultStem: "IMG_002")
        var planner: BatchImageFilenamePlanner = .init()

        planner.setEditableFilenameStem("shared.png", for: firstItem)
        planner.setEditableFilenameStem("shared.jpg", for: secondItem)

        let resolvedFilenames = planner.resolvedFilenames(
            for: [firstItem, secondItem]
        )

        #expect(planner.editableFilenameStem(for: firstItem) == "shared")
        #expect(planner.editableFilenameStem(for: secondItem) == "shared")
        #expect(resolvedFilenames[firstItem.id] == "shared.jpeg")
        #expect(resolvedFilenames[secondItem.id] == "shared-2.jpeg")
    }
}

private extension BatchImageFilenamePlannerTests {
    func makeItem(
        defaultStem: String,
        outputFormat: ImageFileFormat = .jpeg
    ) -> BatchImageFilenamePlanner.Item {
        .init(
            id: .init(),
            defaultStem: defaultStem,
            outputFormat: outputFormat
        )
    }
}
