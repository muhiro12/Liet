import SwiftUI

enum BatchTextRole {
    case screenTitle
    case sectionTitle
    case bodyStrong
    case supporting
    case metadata
    case caption

    var font: Font {
        switch self {
        case .screenTitle:
            .title3.weight(.semibold)
        case .sectionTitle:
            .headline
        case .bodyStrong:
            .subheadline.weight(.semibold)
        case .supporting:
            .subheadline
        case .metadata:
            .footnote.weight(.medium)
        case .caption:
            .footnote
        }
    }
}

extension View {
    func batchTextStyle(
        _ role: BatchTextRole,
        color: Color = .primary
    ) -> some View {
        font(role.font)
            .foregroundStyle(color)
    }
}
