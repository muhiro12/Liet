import Foundation

public enum ImageFileFormat: String, CaseIterable, Codable, Sendable {
    case jpeg
    case png
    case heic
    case other
}

public extension ImageFileFormat {
    init(typeIdentifier: String?) {
        let normalizedIdentifier = typeIdentifier?.lowercased() ?? ""

        switch normalizedIdentifier {
        case "public.jpeg", "public.jpg":
            self = .jpeg
        case "public.png":
            self = .png
        case "public.heic", "public.heif":
            self = .heic
        default:
            self = .other
        }
    }

    var displayName: String {
        switch self {
        case .jpeg:
            "JPEG"
        case .png:
            "PNG"
        case .heic:
            "HEIC"
        case .other:
            "JPEG"
        }
    }

    var filenameExtension: String {
        switch self {
        case .jpeg:
            "jpg"
        case .png:
            "png"
        case .heic:
            "heic"
        case .other:
            "jpg"
        }
    }

    var sourceTypeIdentifier: String {
        switch self {
        case .jpeg:
            "public.jpeg"
        case .png:
            "public.png"
        case .heic:
            "public.heic"
        case .other:
            "public.jpeg"
        }
    }

    var supportsLossyCompressionQuality: Bool {
        switch self {
        case .jpeg, .heic:
            true
        case .png, .other:
            false
        }
    }

    var preferredOutputFormat: Self {
        switch self {
        case .other:
            .jpeg
        case .jpeg, .png, .heic:
            self
        }
    }

    var requiresOutputFallback: Bool {
        self == .other
    }
}
