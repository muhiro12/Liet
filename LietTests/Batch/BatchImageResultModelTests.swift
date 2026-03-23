import Foundation
@testable import Liet
import LietLibrary
import Testing
import UIKit

@MainActor
struct BatchImageResultModelTests {
    @Test
    func result_messages_follow_injected_localization() throws {
        let localization = BatchImageLocalization(
            locale: .init(identifier: "ja"),
            bundle: Bundle(for: BatchImageHomeModel.self)
        )
        let firstImage = makeProcessedImage(filename: "first.jpg")
        let secondImage = makeProcessedImage(filename: "second.jpg")
        let model = BatchImageResultModel(
            outcome: .init(
                processedImages: [firstImage, secondImage],
                failureCount: 3,
                jpegFallbackCount: 1,
                ignoredCompressionCount: 2
            ),
            localization: localization
        )

        #expect(model.titleText == "2 枚の画像を処理しました")
        #expect(
            model.detailMessages == [
                "3 枚の画像を処理できませんでした。",
                "元の形式を保持できなかったため、1 枚を JPEG として書き出しました。",
                "PNG 画像では圧縮品質の設定は適用されません。"
            ]
        )

        model.handleFileExportCompletion(
            .success([firstImage.outputURL, secondImage.outputURL])
        )

        #expect(model.saveMessage == "2 枚の画像をファイルに保存しました。")
    }

    func makeProcessedImage(
        filename: String
    ) -> ProcessedBatchImage {
        .init(
            sourceID: .init(),
            outputURL: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathComponent(filename),
            outputFilename: filename,
            outputFormat: .jpeg,
            originalFormat: .jpeg,
            pixelSize: .init(width: 200, height: 100),
            previewImage: UIImage(),
            usedJPEGFallback: false,
            ignoredCompressionSetting: false
        )
    }
}
