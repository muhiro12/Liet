import Foundation
import LietLibrary
import UIKit

struct ImportedBatchImage: Identifiable {
    let id: UUID
    let sourceURL: URL
    let originalFilename: String?
    let originalFormat: ImageFileFormat
    let pixelSize: CGSize
    let previewImage: UIImage
    let selectionIndex: Int

    nonisolated init(
        sourceURL: URL,
        originalFilename: String?,
        originalFormat: ImageFileFormat,
        pixelSize: CGSize,
        previewImage: UIImage,
        selectionIndex: Int,
        id: UUID = .init()
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.originalFilename = originalFilename
        self.originalFormat = originalFormat
        self.pixelSize = pixelSize
        self.previewImage = previewImage
        self.selectionIndex = selectionIndex
    }
}

extension ImportedBatchImage {
    var displayName: String {
        if let originalFilename,
           !originalFilename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return URL(fileURLWithPath: originalFilename).lastPathComponent
        }

        let formattedSelectionIndex = String(
            format: "%03d",
            selectionIndex
        )
        return String(
            localized: "Image \(formattedSelectionIndex)"
        )
    }

    var detailText: String {
        "\(originalFormat.displayName) • \(Int(pixelSize.width))×\(Int(pixelSize.height))"
    }
}
