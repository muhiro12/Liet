import Foundation

/// Image file formats recognized by the batch processor.
public enum ImageFileFormat: String, CaseIterable, Codable, Sendable {
    /// JPEG input or output.
    case jpeg
    /// PNG input or output.
    case png
    /// HEIC input or output.
    case heic
    /// Any unsupported format that falls back to JPEG output.
    case other
}

public extension ImageFileFormat {
    /// User-facing format label shown in the UI.
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

    /// Preferred file extension used for output filenames.
    var filenameExtension: String {
        switch self {
        case .jpeg:
            "jpeg"
        case .png:
            "png"
        case .heic:
            "heic"
        case .other:
            "jpeg"
        }
    }

    /// Uniform type identifier used for Image I/O reads and writes.
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

    /// Whether the format supports a lossy compression quality parameter.
    var supportsLossyCompressionQuality: Bool {
        switch self {
        case .jpeg, .heic:
            true
        case .png, .other:
            false
        }
    }

    /// Preferred output format after applying MVP fallback rules.
    var preferredOutputFormat: Self {
        switch self {
        case .other:
            .jpeg
        case .jpeg, .png, .heic:
            self
        }
    }

    /// Whether the format requires JPEG fallback on export.
    var requiresOutputFallback: Bool {
        self == .other
    }

    /// Resolves a format from an input type identifier.
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
}
