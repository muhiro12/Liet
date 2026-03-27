import CoreGraphics
@testable import LietLibrary
import Testing

struct BatchBackgroundRemovalPlannerTests {
    @Test
    func make_plan_uses_png_output_and_preserves_original_size() {
        let plan = BatchBackgroundRemovalPlanner.makePlan(
            for: .init(
                originalPixelSize: .init(width: 1_600, height: 900),
                selectionIndex: 1
            ),
            naming: .default
        )

        #expect(plan.outputFormat == .png)
        #expect(plan.outputFilename == "IMG_001.png")
        #expect(Int(plan.outputPixelSize.width) == 1_600)
        #expect(Int(plan.outputPixelSize.height) == 900)
    }

    @Test
    func make_plan_uses_selected_naming_template_and_deduplicates_filenames() {
        let plan = BatchBackgroundRemovalPlanner.makePlan(
            for: .init(
                originalPixelSize: .init(width: 900, height: 1_600),
                selectionIndex: 1
            ),
            naming: .init(
                template: .processed,
                numberingStyle: .plain
            ),
            existingFilenames: ["processed_1.png"]
        )

        #expect(plan.outputFilename == "processed_1-2.png")
    }
}
