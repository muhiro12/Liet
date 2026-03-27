import Foundation

/// The numbering format appended to generated output filenames.
public enum BatchImageNumberingStyle: String, CaseIterable, Codable, Sendable {
    case zeroPaddedThreeDigits = "zero_padded_three_digits"
    case plain

    func formattedNumber(
        for selectionIndex: Int
    ) -> String {
        let resolvedIndex = max(1, selectionIndex)

        switch self {
        case .zeroPaddedThreeDigits:
            return String(format: "%03d", resolvedIndex)
        case .plain:
            return "\(resolvedIndex)"
        }
    }
}
