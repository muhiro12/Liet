import Foundation

struct BatchImageLocalization {
    private enum Key: String {
        case selectedImageCountSingle = "batch.selection.count.single"
        case selectedImageCountMultiple = "batch.selection.count.multiple"
        case importFailureSingle = "batch.import.failure.single"
        case importFailureMultiple = "batch.import.failure.multiple"
        case importSelectionFailed = "batch.import.selection.failed"
        case invalidLongEdgeSize = "batch.validation.longEdge.invalid"
        case processSelectionFailed = "batch.process.selection.failed"
        case resultReadySingle = "batch.result.ready.single"
        case resultReadyMultiple = "batch.result.ready.multiple"
        case resultFailureSingle = "batch.result.failure.single"
        case resultFailureMultiple = "batch.result.failure.multiple"
        case jpegFallbackSingle = "batch.result.jpegFallback.single"
        case jpegFallbackMultiple = "batch.result.jpegFallback.multiple"
        case pngCompressionSingle = "batch.result.pngCompression.single"
        case pngCompressionMultiple = "batch.result.pngCompression.multiple"
        case exportFilesSingle = "batch.export.files.single"
        case exportFilesMultiple = "batch.export.files.multiple"
        case exportPhotosSingle = "batch.export.photos.single"
        case exportPhotosMultiple = "batch.export.photos.multiple"
        case failedToLoadImageData = "batch.error.failedToLoadImageData"
        case failedToCreateImageSource = "batch.error.failedToCreateImageSource"
        case failedToReadImageProperties = "batch.error.failedToReadImageProperties"
        case failedToCreateThumbnail = "batch.error.failedToCreateThumbnail"
        case failedToEncodeImage = "batch.error.failedToEncodeImage"
        case photoLibraryPermissionDenied = "batch.error.photoLibraryPermissionDenied"
        case photoLibrarySaveFailed = "batch.error.photoLibrarySaveFailed"

        nonisolated var defaultValue: String {
            switch self {
            case .selectedImageCountSingle:
                "1 image selected"
            case .selectedImageCountMultiple:
                "%@ images selected"
            case .importFailureSingle:
                "1 image couldn't be loaded."
            case .importFailureMultiple:
                "%@ images couldn't be loaded."
            case .importSelectionFailed:
                "Couldn't import the selected images."
            case .invalidLongEdgeSize:
                "Enter a valid long-edge size."
            case .processSelectionFailed:
                "Couldn't process the selected images."
            case .resultReadySingle:
                "1 image ready"
            case .resultReadyMultiple:
                "%@ images ready"
            case .resultFailureSingle:
                "1 image couldn't be processed."
            case .resultFailureMultiple:
                "%@ images couldn't be processed."
            case .jpegFallbackSingle:
                "1 image was exported as JPEG because the original format couldn't be preserved."
            case .jpegFallbackMultiple:
                "%@ images were exported as JPEG because the original format couldn't be preserved."
            case .pngCompressionSingle:
                "PNG ignores the compression quality setting."
            case .pngCompressionMultiple:
                "PNG images ignore the compression quality setting."
            case .exportFilesSingle:
                "Exported 1 image to Files."
            case .exportFilesMultiple:
                "Exported %@ images to Files."
            case .exportPhotosSingle:
                "Saved 1 image to Photos."
            case .exportPhotosMultiple:
                "Saved %@ images to Photos."
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
    }

    nonisolated let locale: Locale
    nonisolated let bundle: Bundle

    nonisolated init(
        locale: Locale = .autoupdatingCurrent,
        bundle: Bundle = .batchImageLocalization
    ) {
        self.locale = locale
        self.bundle = bundle
    }
}

extension BatchImageLocalization {
    nonisolated func selectedImageCount(
        _ count: Int
    ) -> String {
        if count == 1 {
            return string(.selectedImageCountSingle)
        }

        return formattedString(
            .selectedImageCountMultiple,
            count: count
        )
    }

    nonisolated func importFailureMessage(
        count: Int
    ) -> String {
        if count == 1 {
            return string(.importFailureSingle)
        }

        return formattedString(
            .importFailureMultiple,
            count: count
        )
    }

    nonisolated func importSelectionFailedMessage() -> String {
        string(.importSelectionFailed)
    }

    nonisolated func invalidLongEdgeSizeMessage() -> String {
        string(.invalidLongEdgeSize)
    }

    nonisolated func processSelectionFailedMessage() -> String {
        string(.processSelectionFailed)
    }

    nonisolated func resultReadyTitle(
        count: Int
    ) -> String {
        if count == 1 {
            return string(.resultReadySingle)
        }

        return formattedString(
            .resultReadyMultiple,
            count: count
        )
    }

    nonisolated func resultFailureMessage(
        count: Int
    ) -> String {
        if count == 1 {
            return string(.resultFailureSingle)
        }

        return formattedString(
            .resultFailureMultiple,
            count: count
        )
    }

    nonisolated func jpegFallbackMessage(
        count: Int
    ) -> String {
        if count == 1 {
            return string(.jpegFallbackSingle)
        }

        return formattedString(
            .jpegFallbackMultiple,
            count: count
        )
    }

    nonisolated func pngCompressionMessage(
        count: Int
    ) -> String {
        if count == 1 {
            return string(.pngCompressionSingle)
        }

        return string(.pngCompressionMultiple)
    }

    nonisolated func exportFilesSuccessMessage(
        count: Int
    ) -> String {
        if count == 1 {
            return string(.exportFilesSingle)
        }

        return formattedString(
            .exportFilesMultiple,
            count: count
        )
    }

    nonisolated func exportPhotosSuccessMessage(
        count: Int
    ) -> String {
        if count == 1 {
            return string(.exportPhotosSingle)
        }

        return formattedString(
            .exportPhotosMultiple,
            count: count
        )
    }

    nonisolated func serviceErrorMessage(
        _ error: BatchImageServiceError
    ) -> String {
        switch error {
        case .failedToLoadImageData:
            string(.failedToLoadImageData)
        case .failedToCreateImageSource:
            string(.failedToCreateImageSource)
        case .failedToReadImageProperties:
            string(.failedToReadImageProperties)
        case .failedToCreateThumbnail:
            string(.failedToCreateThumbnail)
        case .failedToEncodeImage:
            string(.failedToEncodeImage)
        case .photoLibraryPermissionDenied:
            string(.photoLibraryPermissionDenied)
        case .photoLibrarySaveFailed:
            string(.photoLibrarySaveFailed)
        }
    }
}

private extension BatchImageLocalization {
    nonisolated private func string(
        _ key: Key
    ) -> String {
        localizedBundle.localizedString(
            forKey: key.rawValue,
            value: key.defaultValue,
            table: "Localizable"
        )
    }

    nonisolated private func formattedString(
        _ key: Key,
        count: Int
    ) -> String {
        let localizedCount = count.formatted(
            .number.locale(locale)
        )

        return String(
            format: string(key),
            locale: locale,
            localizedCount
        )
    }

    nonisolated var localizedBundle: Bundle {
        let preferredLocalizations = localizationPreferences()
        let availableLocalizations = bundle.localizations

        guard let localization = Bundle.preferredLocalizations(
            from: availableLocalizations,
            forPreferences: preferredLocalizations
        ).first,
        let path = bundle.path(
            forResource: localization,
            ofType: "lproj"
        ),
        let localizedBundle = Bundle(path: path) else {
            return bundle
        }

        return localizedBundle
    }

    nonisolated func localizationPreferences() -> [String] {
        let languageCode = locale.language.languageCode?.identifier

        return [
            locale.identifier,
            languageCode,
            bundle.developmentLocalization
        ]
        .compactMap { localization in
            localization
        }
    }
}

private extension Bundle {
    nonisolated static var batchImageLocalization: Bundle {
        Bundle(for: BatchImageLocalizationBundleToken.self)
    }
}

private final class BatchImageLocalizationBundleToken {}
