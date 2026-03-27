import Foundation

/// Shared output naming settings applied to every processed image.
public struct BatchImageNaming: Equatable, Codable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case customPrefix = "P9f2Hx4L"
        case numberingStyle = "N6q3Vr8C"
        case template = "T4m7Ks1D"
    }

    /// Repository defaults for output naming.
    public static let `default`: Self = .init(
        template: .img,
        customPrefix: "",
        numberingStyle: .zeroPaddedThreeDigits
    )

    /// The selected prefix template.
    public var template: BatchImageNamingTemplate
    /// The custom prefix entered by the user when the custom template is selected.
    public var customPrefix: String
    /// The numbering style appended to the selected prefix.
    public var numberingStyle: BatchImageNumberingStyle

    /// Whether the selected naming configuration can generate output stems.
    public var isValid: Bool {
        resolvedPrefix != nil
    }

    private var resolvedPrefix: String? {
        template.resolvedPrefix(
            customPrefix: customPrefix
        )
    }

    /// Creates shared output naming settings with repository defaults.
    public init(
        template: BatchImageNamingTemplate = Self.default.template,
        customPrefix: String = Self.default.customPrefix,
        numberingStyle: BatchImageNumberingStyle = Self.default.numberingStyle
    ) {
        self.template = template
        self.customPrefix = customPrefix
        self.numberingStyle = numberingStyle
    }

    /// Generates the shared output filename stem for a selection index.
    public func filenameStem(
        for selectionIndex: Int
    ) -> String? {
        guard let resolvedPrefix else {
            return nil
        }

        return "\(resolvedPrefix)_\(numberingStyle.formattedNumber(for: selectionIndex))"
    }
}
