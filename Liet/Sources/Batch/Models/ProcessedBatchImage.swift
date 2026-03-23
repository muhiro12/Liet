import Foundation
import LietLibrary
import UIKit
import UniformTypeIdentifiers

struct ProcessedBatchImage: Identifiable {
    let id: UUID
    let sourceID: UUID
    let outputURL: URL
    let outputFilename: String
    let outputFormat: ImageFileFormat
    let originalFormat: ImageFileFormat
    let pixelSize: CGSize
    let previewImage: UIImage
    let usedJPEGFallback: Bool
    let ignoredCompressionSetting: Bool

    nonisolated init(
        sourceID: UUID,
        outputURL: URL,
        outputFilename: String,
        outputFormat: ImageFileFormat,
        originalFormat: ImageFileFormat,
        pixelSize: CGSize,
        previewImage: UIImage,
        usedJPEGFallback: Bool,
        ignoredCompressionSetting: Bool,
        id: UUID = .init()
    ) {
        self.id = id
        self.sourceID = sourceID
        self.outputURL = outputURL
        self.outputFilename = outputFilename
        self.outputFormat = outputFormat
        self.originalFormat = originalFormat
        self.pixelSize = pixelSize
        self.previewImage = previewImage
        self.usedJPEGFallback = usedJPEGFallback
        self.ignoredCompressionSetting = ignoredCompressionSetting
    }
}

extension ProcessedBatchImage {
    var detailText: String {
        "\(outputFormat.displayName) • \(Int(pixelSize.width))×\(Int(pixelSize.height))"
    }

    var defaultOutputStem: String {
        URL(fileURLWithPath: outputFilename)
            .deletingPathExtension()
            .lastPathComponent
    }

    var outputFilenameExtension: String {
        outputFormat.filenameExtension
    }

    var contentType: UTType {
        ImageIOImageSupport.contentType(for: outputFormat)
    }
}
