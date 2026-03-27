import Foundation

struct BatchImagePreviewItem: Identifiable {
    let id: UUID
    let displayName: String
    let detailText: String
    let imageURL: URL
    let pixelSize: CGSize
}

extension BatchImagePreviewItem {
    init(
        importedImage: ImportedBatchImage
    ) {
        self.init(
            id: importedImage.id,
            displayName: importedImage.displayName,
            detailText: importedImage.detailText,
            imageURL: importedImage.sourceURL,
            pixelSize: importedImage.pixelSize
        )
    }

    init(
        processedImage: ProcessedBatchImage,
        displayName: String? = nil
    ) {
        self.init(
            id: processedImage.id,
            displayName: displayName ?? processedImage.outputFilename,
            detailText: processedImage.detailText,
            imageURL: processedImage.outputURL,
            pixelSize: processedImage.pixelSize
        )
    }
}
