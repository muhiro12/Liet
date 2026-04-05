import Foundation

enum BatchFeatureKind: String, CaseIterable, Identifiable {
    case resizeImages = "resize_images"
    case removeBackground = "remove_background"

    var id: String {
        rawValue
    }

    var systemImage: String {
        switch self {
        case .resizeImages:
            "arrow.up.left.and.arrow.down.right"
        case .removeBackground:
            "wand.and.stars"
        }
    }
}
