import CoreGraphics
@testable import LietLibrary
import Testing

struct BatchImageProcessingPlannerTests {
    @Test
    func heic_output_falls_back_to_jpeg_when_the_encoder_is_unavailable() {
        #expect(
            BatchImageProcessingPlanner.resolvedOutputFormat(
                for: .heic,
                heicEncoderAvailable: true
            ) == .heic
        )
        #expect(
            BatchImageProcessingPlanner.resolvedOutputFormat(
                for: .heic,
                heicEncoderAvailable: false
            ) == .jpeg
        )
    }

    @Test
    func fit_within_projection_uses_the_selected_reference_edge_without_upscaling() {
        let portraitProjection = BatchImageProcessingPlanner.projectedPixelSize(
            originalPixelSize: .init(width: 1_000, height: 2_000),
            resizeMode: .fitWithin(
                referenceDimension: .height,
                pixels: 500
            )
        )
        let smallProjection = BatchImageProcessingPlanner.projectedPixelSize(
            originalPixelSize: .init(width: 200, height: 100),
            resizeMode: .fitWithin(
                referenceDimension: .width,
                pixels: 1_920
            )
        )

        #expect(Int(portraitProjection.width) == 250)
        #expect(Int(portraitProjection.height) == 500)
        #expect(Int(smallProjection.width) == 200)
        #expect(Int(smallProjection.height) == 100)
    }

    @Test
    func exact_size_projection_returns_the_requested_canvas() {
        let projection = BatchImageProcessingPlanner.projectedPixelSize(
            originalPixelSize: .init(width: 400, height: 200),
            resizeMode: .exactSize(
                widthPixels: 100,
                heightPixels: 80,
                strategy: .coverCrop
            )
        )

        #expect(Int(projection.width) == 100)
        #expect(Int(projection.height) == 80)
    }

    @Test
    func copy_original_requires_preserved_format_size_and_compression() {
        let originalPixelSize = CGSize(width: 320, height: 180)
        let copyPreservingPlan = BatchImageProcessingPlanner.shouldCopyOriginal(
            originalFormat: .jpeg,
            originalPixelSize: originalPixelSize,
            settings: .init(
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 1_920
                ),
                compression: .off
            ),
            outputFormat: .jpeg
        )
        let recompressingPlan = BatchImageProcessingPlanner.shouldCopyOriginal(
            originalFormat: .jpeg,
            originalPixelSize: originalPixelSize,
            settings: .init(
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 1_920
                ),
                compression: .medium
            ),
            outputFormat: .jpeg
        )
        let resizingPlan = BatchImageProcessingPlanner.shouldCopyOriginal(
            originalFormat: .jpeg,
            originalPixelSize: originalPixelSize,
            settings: .init(
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 200
                ),
                compression: .off
            ),
            outputFormat: .jpeg
        )

        #expect(copyPreservingPlan)
        #expect(recompressingPlan == false)
        #expect(resizingPlan == false)
    }

    @Test
    func make_plan_resolves_output_names_sizes_and_summary_flags() {
        let settings = BatchImageSettings(
            resizeMode: .fitWithin(
                referenceDimension: .width,
                pixels: 800
            ),
            compression: .medium
        )
        let heicPlan = BatchImageProcessingPlanner.makePlan(
            for: .init(
                originalFormat: .heic,
                originalPixelSize: .init(width: 1_600, height: 900),
                selectionIndex: 1
            ),
            settings: settings,
            heicEncoderAvailable: false
        )
        let pngPlan = BatchImageProcessingPlanner.makePlan(
            for: .init(
                originalFormat: .png,
                originalPixelSize: .init(width: 300, height: 200),
                selectionIndex: 3
            ),
            settings: settings,
            heicEncoderAvailable: false,
            existingFilenames: [heicPlan.outputFilename]
        )
        let summary = BatchImageProcessingPlanner.summarize(
            plans: [heicPlan, pngPlan]
        )

        #expect(heicPlan.outputFormat == .jpeg)
        #expect(heicPlan.outputFilename == "IMG_001.jpeg")
        #expect(Int(heicPlan.outputPixelSize.width) == 800)
        #expect(Int(heicPlan.outputPixelSize.height) == 450)
        #expect(heicPlan.usedJPEGFallback)
        #expect(heicPlan.shouldCopyOriginal == false)

        #expect(pngPlan.outputFormat == .png)
        #expect(pngPlan.outputFilename == "IMG_003.png")
        #expect(pngPlan.ignoredCompressionSetting)

        #expect(summary.jpegFallbackCount == 1)
        #expect(summary.ignoredCompressionCount == 1)
    }

    @Test
    func make_plan_uses_selected_naming_template_and_numbering_style() {
        let processedPlan = BatchImageProcessingPlanner.makePlan(
            for: .init(
                originalFormat: .jpeg,
                originalPixelSize: .init(width: 1_000, height: 1_000),
                selectionIndex: 2
            ),
            settings: .init(
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 800
                ),
                compression: .off,
                naming: .init(
                    template: .processed,
                    numberingStyle: .plain
                )
            ),
            heicEncoderAvailable: true
        )
        let customPlan = BatchImageProcessingPlanner.makePlan(
            for: .init(
                originalFormat: .jpeg,
                originalPixelSize: .init(width: 1_000, height: 1_000),
                selectionIndex: 5
            ),
            settings: .init(
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 800
                ),
                compression: .off,
                naming: .init(
                    template: .custom,
                    customPrefix: "receipt.png",
                    numberingStyle: .zeroPaddedThreeDigits
                )
            ),
            heicEncoderAvailable: true
        )

        #expect(processedPlan.outputFilename == "processed_2.jpeg")
        #expect(customPlan.outputFilename == "receipt_005.jpeg")
    }
}
