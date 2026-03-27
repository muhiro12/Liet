import Foundation

enum BatchFeatureKind: String, CaseIterable, Identifiable {
    case resizeImages = "resize_images"
    case removeBackground = "remove_background"

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .resizeImages:
            "Resize Images"
        case .removeBackground:
            "Remove Background"
        }
    }

    var subtitle: String {
        switch self {
        case .resizeImages:
            "Apply one shared output size, compression, and naming setup to the full batch."
        case .removeBackground:
            "Create transparent PNG copies with one shared background-removal setup."
        }
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
