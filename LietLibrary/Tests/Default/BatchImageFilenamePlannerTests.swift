@testable import LietLibrary
import Testing

struct BatchImageFilenamePlannerTests {
    @Test
    func blank_custom_stems_fall_back_to_default_output_names() {
        let firstItem = makeItem(defaultStem: "first-Liet")
        let secondItem = makeItem(defaultStem: "second-Liet")
        var planner: BatchImageFilenamePlanner = .init()

        planner.setEditableFilenameStem("", for: firstItem)
        planner.setEditableFilenameStem("shared.jpg", for: secondItem)

        #expect(
            planner.resolvedFilename(
                for: firstItem,
                within: [firstItem, secondItem]
            ) == "first-Liet.jpg"
        )
        #expect(planner.editableFilenameStem(for: secondItem) == "shared")
        #expect(
            planner.resolvedFilename(
                for: secondItem,
                within: [firstItem, secondItem]
            ) == "shared.jpg"
        )
    }

    @Test
    func duplicate_custom_stems_are_deduplicated_in_item_order() {
        let firstItem = makeItem(defaultStem: "first-Liet")
        let secondItem = makeItem(defaultStem: "second-Liet")
        var planner: BatchImageFilenamePlanner = .init()

        planner.setEditableFilenameStem("shared", for: firstItem)
        planner.setEditableFilenameStem("shared", for: secondItem)

        let resolvedFilenames = planner.resolvedFilenames(
            for: [firstItem, secondItem]
        )

        #expect(resolvedFilenames[firstItem.id] == "shared.jpg")
        #expect(resolvedFilenames[secondItem.id] == "shared-2.jpg")
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
