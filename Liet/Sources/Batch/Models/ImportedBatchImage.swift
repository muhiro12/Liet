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
        id: UUID = .init(),
        sourceURL: URL,
        originalFilename: String?,
        originalFormat: ImageFileFormat,
        pixelSize: CGSize,
        previewImage: UIImage,
        selectionIndex: Int
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

        return String(
            format: "Image %03d",
            selectionIndex
        )
    }

    var detailText: String {
        "\(originalFormat.displayName) • \(Int(pixelSize.width))×\(Int(pixelSize.height))"
    }
}
