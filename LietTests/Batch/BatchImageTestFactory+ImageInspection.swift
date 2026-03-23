import CoreGraphics
import Foundation
import ImageIO
@testable import Liet

extension BatchImageTestFactory {
    static func detectedTypeIdentifier(
        for url: URL
    ) throws -> String {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw Failure.failedToCreateImageSource
        }

        guard let typeIdentifier = CGImageSourceGetType(imageSource) as String? else {
            throw Failure.failedToReadTypeIdentifier
        }

        return typeIdentifier
    }

    static func pixelSample(
        from url: URL,
        sampleX: Int,
        sampleY: Int
    ) throws -> PixelSample {
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw Failure.failedToCreateImageSource
        }

        let width = image.width
        let height = image.height
        var bytes = [UInt8](
            repeating: 0,
            count: width * height * bytesPerPixel
        )
        guard let context = CGContext(
            data: &bytes,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: width * bytesPerPixel,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw Failure.failedToCreateImageData
        }

        context.draw(
            image,
            in: CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height
            )
        )

        let clampedX = min(
            max(sampleX, 0),
            width - 1
        )
        let clampedY = min(
            max(sampleY, 0),
            height - 1
        )
        let index = (clampedY * width + clampedX) * bytesPerPixel

        return .init(
            red: bytes[index],
            green: bytes[index + 1],
            blue: bytes[index + 2],
            alpha: bytes[index + 3]
        )
    }
}
