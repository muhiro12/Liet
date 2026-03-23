import Foundation
import Photos
@testable import Liet
import LietLibrary
import Testing

struct PhotoLibrarySaveServiceTests {
    @Test
    func asset_resource_inputs_use_photo_resources_and_output_filenames() throws {
        let firstImage = try Self.makeProcessedImage(
            outputFilename: "alpha-output.png",
            outputFormat: .png
        )
        let secondImage = try Self.makeProcessedImage(
            outputFilename: "banner-output.jpg",
            outputFormat: .jpeg
        )

        let inputs = PhotoLibrarySaveService.assetResourceInputs(
            for: [firstImage, secondImage]
        )

        #expect(inputs.count == 2)
        #expect(inputs[0].resourceType == .photo)
        #expect(inputs[0].fileURL == firstImage.outputURL)
        #expect(inputs[0].originalFilename == firstImage.outputFilename)
        #expect(inputs[1].resourceType == .photo)
        #expect(inputs[1].fileURL == secondImage.outputURL)
        #expect(inputs[1].originalFilename == secondImage.outputFilename)
    }
}

private extension PhotoLibrarySaveServiceTests {
    static func makeProcessedImage(
        outputFilename: String,
        outputFormat: ImageFileFormat
    ) throws -> ProcessedBatchImage {
        let previewImage = BatchImageTestFactory.makeUIImage(
            size: CGSize(width: 80, height: 60)
        )
        let outputURL = try BatchImageTestFactory.writeImageData(
            for: previewImage,
            format: outputFormat,
            filename: outputFilename
        )

        return .init(
            sourceID: .init(),
            outputURL: outputURL,
            outputFilename: outputFilename,
            outputFormat: outputFormat,
            originalFormat: outputFormat,
            pixelSize: CGSize(width: 80, height: 60),
            previewImage: previewImage,
            usedJPEGFallback: false,
            ignoredCompressionSetting: outputFormat == .png
        )
    }
}
