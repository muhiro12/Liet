import CoreGraphics

extension CGImage {
    var batchHasAlphaChannel: Bool {
        switch alphaInfo {
        case .alphaOnly,
             .first,
             .last,
             .premultipliedFirst,
             .premultipliedLast:
            true
        case .none,
             .noneSkipFirst,
             .noneSkipLast:
            false
        @unknown default:
            false
        }
    }
}
