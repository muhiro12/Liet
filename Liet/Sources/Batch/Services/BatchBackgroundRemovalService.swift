import CoreImage
import Foundation
import LietLibrary
import Vision

enum BatchBackgroundRemovalService {
    private enum Constants {
        nonisolated static let identityContrast = CGFloat(1)
        nonisolated static let contrastRangeSpan = identityContrast + identityContrast
        nonisolated static let halfContrastPivot = identityContrast / contrastRangeSpan
        nonisolated static let maximumExpansionRadius = 12.0
        nonisolated static let maximumSmoothingRadius = 10.0
        nonisolated static let maximumStrengthContrastBoost = 1.8
        nonisolated static let unitIntervalUpperBound = CGFloat(1)
    }
}

extension BatchBackgroundRemovalService {
    nonisolated static func removedBackgroundImage(
        from image: CGImage,
        settings: BatchBackgroundRemovalSettings
    ) throws -> CGImage {
        let requestHandler = VNImageRequestHandler(
            cgImage: image,
            options: [:]
        )
        let request = VNGenerateForegroundInstanceMaskRequest()
        try requestHandler.perform([request])

        guard let observation = request.results?.first,
              !observation.allInstances.isEmpty else {
            throw BatchImageServiceError.failedToRemoveBackground
        }

        let maskBuffer = try observation.generateScaledMaskForImage(
            forInstances: observation.allInstances,
            from: requestHandler
        )
        let extent = CGRect(
            x: 0,
            y: 0,
            width: image.width,
            height: image.height
        )
        let maskImage = try adjustedMaskImage(
            from: maskBuffer,
            settings: settings,
            extent: extent
        )
        let sourceImage = CIImage(
            cgImage: image
        )
        let clearBackground = CIImage(
            color: .clear
        )
        .cropped(to: extent)

        guard let filter = CIFilter(
            name: "CIBlendWithMask"
        ) else {
            throw BatchImageServiceError.failedToRemoveBackground
        }

        filter.setValue(sourceImage, forKey: kCIInputImageKey)
        filter.setValue(clearBackground, forKey: kCIInputBackgroundImageKey)
        filter.setValue(maskImage, forKey: kCIInputMaskImageKey)

        guard let outputImage = filter.outputImage,
              let outputCGImage = CIContext().createCGImage(
                outputImage,
                from: extent
              ) else {
            throw BatchImageServiceError.failedToRemoveBackground
        }

        return outputCGImage
    }
}

private extension BatchBackgroundRemovalService {
    nonisolated static func adjustedMaskImage(
        from maskBuffer: CVPixelBuffer,
        settings: BatchBackgroundRemovalSettings,
        extent: CGRect
    ) throws -> CIImage {
        let maskImage = CIImage(
            cvPixelBuffer: maskBuffer
        )
        .cropped(to: extent)
        let edgeAdjustedMask = try adjustedMaskEdges(
            maskImage,
            settings: settings,
            extent: extent
        )

        return try clampedMaskImage(
            from: edgeAdjustedMask,
            settings: settings,
            extent: extent
        )
    }

    nonisolated static func adjustedMaskEdges(
        _ maskImage: CIImage,
        settings: BatchBackgroundRemovalSettings,
        extent: CGRect
    ) throws -> CIImage {
        let expandedMask = try expandedMaskImage(
            from: maskImage,
            settings: settings,
            extent: extent
        )

        return try smoothedMaskImage(
            from: expandedMask,
            settings: settings,
            extent: extent
        )
    }

    nonisolated static func expandedMaskImage(
        from maskImage: CIImage,
        settings: BatchBackgroundRemovalSettings,
        extent: CGRect
    ) throws -> CIImage {
        guard settings.edgeExpansion != 0 else {
            return maskImage
        }

        let filterName = settings.edgeExpansion > 0
            ? "CIMorphologyMaximum"
            : "CIMorphologyMinimum"
        return try filteredImage(
            maskImage,
            filterName: filterName,
            parameters: [
                kCIInputRadiusKey: abs(settings.edgeExpansion) * Constants.maximumExpansionRadius
            ],
            extent: extent
        )
    }

    nonisolated static func smoothedMaskImage(
        from maskImage: CIImage,
        settings: BatchBackgroundRemovalSettings,
        extent: CGRect
    ) throws -> CIImage {
        guard settings.edgeSmoothing > 0 else {
            return maskImage
        }

        return try filteredImage(
            maskImage,
            filterName: "CIGaussianBlur",
            parameters: [
                kCIInputRadiusKey: settings.edgeSmoothing * Constants.maximumSmoothingRadius
            ],
            extent: extent
        )
    }

    nonisolated static func clampedMaskImage(
        from maskImage: CIImage,
        settings: BatchBackgroundRemovalSettings,
        extent: CGRect
    ) throws -> CIImage {
        let contrast = Constants.identityContrast +
            CGFloat(settings.strength) * Constants.maximumStrengthContrastBoost
        let bias = -Constants.halfContrastPivot * (
            contrast - Constants.identityContrast
        )

        let contrastAdjustedMask = try filteredImage(
            maskImage,
            filterName: "CIColorMatrix",
            parameters: [
                "inputRVector": CIVector(x: contrast, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: contrast, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: contrast, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
                "inputBiasVector": CIVector(x: bias, y: bias, z: bias, w: 0)
            ],
            extent: extent
        )

        return try filteredImage(
            contrastAdjustedMask,
            filterName: "CIColorClamp",
            parameters: [
                "inputMinComponents": CIVector(
                    x: 0,
                    y: 0,
                    z: 0,
                    w: 0
                ),
                "inputMaxComponents": CIVector(
                    x: Constants.unitIntervalUpperBound,
                    y: Constants.unitIntervalUpperBound,
                    z: Constants.unitIntervalUpperBound,
                    w: Constants.unitIntervalUpperBound
                )
            ],
            extent: extent
        )
    }

    nonisolated static func filteredImage(
        _ image: CIImage,
        filterName: String,
        parameters: [String: Any],
        extent: CGRect
    ) throws -> CIImage {
        guard let filter = CIFilter(
            name: filterName
        ) else {
            throw BatchImageServiceError.failedToRemoveBackground
        }

        filter.setValue(image, forKey: kCIInputImageKey)

        for (key, value) in parameters {
            filter.setValue(value, forKey: key)
        }

        guard let outputImage = filter.outputImage else {
            throw BatchImageServiceError.failedToRemoveBackground
        }

        return outputImage.cropped(to: extent)
    }
}
