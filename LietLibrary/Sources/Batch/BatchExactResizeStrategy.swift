import Foundation

/// Strategy used when an image is rendered into an exact pixel canvas.
public enum BatchExactResizeStrategy: String, CaseIterable, Codable, Sendable {
    case stretch
    case contain
    // swiftlint:disable:next raw_value_for_camel_cased_codable_enum
    case coverCrop
}
