import Foundation
@testable import Liet
import Testing

struct BatchImageLocalizationTests {
    private let serviceErrors: [BatchImageServiceError] = [
        .failedToLoadImageData,
        .failedToCreateImageSource,
        .failedToReadImageProperties,
        .failedToCreateThumbnail,
        .failedToEncodeImage,
        .photoLibraryPermissionDenied,
        .photoLibrarySaveFailed
    ]

    @Test
    func english_messages_match_expected_copy() {
        let localization = makeLocalization(localeIdentifier: "en")

        #expect(localization.selectedImageCount(1) == "1 image selected")
        #expect(localization.selectedImageCount(3) == "3 images selected")
        #expect(
            localization.importFailureMessage(count: 1) ==
                "1 image couldn't be loaded."
        )
        #expect(
            localization.importFailureMessage(count: 4) ==
                "4 images couldn't be loaded."
        )
        #expect(
            localization.importSelectionFailedMessage() ==
                "Couldn't import the selected images."
        )
        #expect(
            localization.invalidLongEdgeSizeMessage() ==
                "Enter a valid long-edge size."
        )
        #expect(
            localization.processSelectionFailedMessage() ==
                "Couldn't process the selected images."
        )
        #expect(localization.resultReadyTitle(count: 1) == "1 image ready")
        #expect(localization.resultReadyTitle(count: 2) == "2 images ready")
        #expect(
            localization.resultFailureMessage(count: 1) ==
                "1 image couldn't be processed."
        )
        #expect(
            localization.resultFailureMessage(count: 5) ==
                "5 images couldn't be processed."
        )
        #expect(
            localization.jpegFallbackMessage(count: 1) ==
                "1 image was exported as JPEG because the original format couldn't be preserved."
        )
        #expect(
            localization.jpegFallbackMessage(count: 6) ==
                "6 images were exported as JPEG because the original format couldn't be preserved."
        )
        #expect(
            localization.pngCompressionMessage(count: 1) ==
                "PNG ignores the compression quality setting."
        )
        #expect(
            localization.pngCompressionMessage(count: 2) ==
                "PNG images ignore the compression quality setting."
        )
        #expect(
            localization.exportFilesSuccessMessage(count: 1) ==
                "Exported 1 image to Files."
        )
        #expect(
            localization.exportFilesSuccessMessage(count: 3) ==
                "Exported 3 images to Files."
        )
        #expect(
            localization.exportPhotosSuccessMessage(count: 1) ==
                "Saved 1 image to Photos."
        )
        #expect(
            localization.exportPhotosSuccessMessage(count: 7) ==
                "Saved 7 images to Photos."
        )

        for error in serviceErrors {
            #expect(
                localization.serviceErrorMessage(error) ==
                    expectedEnglishServiceErrorMessage(for: error)
            )
        }
    }

    @Test
    func japanese_messages_match_expected_copy() {
        let localization = makeLocalization(localeIdentifier: "ja")

        #expect(localization.selectedImageCount(1) == "1 枚を選択中")
        #expect(localization.selectedImageCount(3) == "3 枚を選択中")
        #expect(
            localization.importFailureMessage(count: 1) ==
                "1 枚の画像を読み込めませんでした。"
        )
        #expect(
            localization.importFailureMessage(count: 4) ==
                "4 枚の画像を読み込めませんでした。"
        )
        #expect(
            localization.importSelectionFailedMessage() ==
                "選択した画像を読み込めませんでした。"
        )
        #expect(
            localization.invalidLongEdgeSizeMessage() ==
                "有効な長辺サイズを入力してください。"
        )
        #expect(
            localization.processSelectionFailedMessage() ==
                "選択した画像を処理できませんでした。"
        )
        #expect(
            localization.resultReadyTitle(count: 1) ==
                "1 枚の画像を処理しました"
        )
        #expect(
            localization.resultReadyTitle(count: 2) ==
                "2 枚の画像を処理しました"
        )
        #expect(
            localization.resultFailureMessage(count: 1) ==
                "1 枚の画像を処理できませんでした。"
        )
        #expect(
            localization.resultFailureMessage(count: 5) ==
                "5 枚の画像を処理できませんでした。"
        )
        #expect(
            localization.jpegFallbackMessage(count: 1) ==
                "元の形式を保持できなかったため、1 枚を JPEG として書き出しました。"
        )
        #expect(
            localization.jpegFallbackMessage(count: 6) ==
                "元の形式を保持できなかったため、6 枚を JPEG として書き出しました。"
        )
        #expect(
            localization.pngCompressionMessage(count: 1) ==
                "PNG では圧縮品質の設定は適用されません。"
        )
        #expect(
            localization.pngCompressionMessage(count: 2) ==
                "PNG 画像では圧縮品質の設定は適用されません。"
        )
        #expect(
            localization.exportFilesSuccessMessage(count: 1) ==
                "1 枚の画像をファイルに保存しました。"
        )
        #expect(
            localization.exportFilesSuccessMessage(count: 3) ==
                "3 枚の画像をファイルに保存しました。"
        )
        #expect(
            localization.exportPhotosSuccessMessage(count: 1) ==
                "1 枚の画像を写真に保存しました。"
        )
        #expect(
            localization.exportPhotosSuccessMessage(count: 7) ==
                "7 枚の画像を写真に保存しました。"
        )

        for error in serviceErrors {
            #expect(
                localization.serviceErrorMessage(error) ==
                    expectedJapaneseServiceErrorMessage(for: error)
            )
        }
    }

    func makeLocalization(
        localeIdentifier: String
    ) -> BatchImageLocalization {
        .init(
            locale: .init(identifier: localeIdentifier),
            bundle: Bundle(for: BatchImageHomeModel.self)
        )
    }

    func expectedEnglishServiceErrorMessage(
        for error: BatchImageServiceError
    ) -> String {
        switch error {
        case .failedToLoadImageData:
            "Couldn't load one of the selected images."
        case .failedToCreateImageSource:
            "Couldn't read one of the selected images."
        case .failedToReadImageProperties:
            "Couldn't inspect one of the selected images."
        case .failedToCreateThumbnail:
            "Couldn't generate an image preview."
        case .failedToEncodeImage:
            "Couldn't write one of the processed images."
        case .photoLibraryPermissionDenied:
            "Photo Library access is required to save images."
        case .photoLibrarySaveFailed:
            "Couldn't save the processed images to Photos."
        }
    }

    func expectedJapaneseServiceErrorMessage(
        for error: BatchImageServiceError
    ) -> String {
        switch error {
        case .failedToLoadImageData:
            "選択した画像の一部を読み込めませんでした。"
        case .failedToCreateImageSource:
            "選択した画像の一部を読み取れませんでした。"
        case .failedToReadImageProperties:
            "選択した画像の一部の情報を取得できませんでした。"
        case .failedToCreateThumbnail:
            "画像のプレビューを生成できませんでした。"
        case .failedToEncodeImage:
            "処理後の画像の一部を書き出せませんでした。"
        case .photoLibraryPermissionDenied:
            "画像を保存するには写真ライブラリへのアクセスが必要です。"
        case .photoLibrarySaveFailed:
            "処理後の画像を写真に保存できませんでした。"
        }
    }
}
