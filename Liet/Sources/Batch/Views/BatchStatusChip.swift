// swiftlint:disable one_declaration_per_file file_types_order
import MHDesign
import SwiftUI

struct BatchStatusChip: View {
    enum Tone: Equatable {
        case accent
        case neutral
        case success
        case warning
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let systemImage: String?
    private let text: Text
    private let tone: Tone

    var body: some View {
        chipContent
            .batchTextStyle(.caption, color: foregroundColor)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .textCase(.uppercase)
            .padding(.horizontal, designMetrics.spacing.control)
            .padding(.vertical, designMetrics.spacing.inline)
            .background(
                backgroundColor,
                in: RoundedRectangle(
                    cornerRadius: designMetrics.radius.control,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: designMetrics.radius.control,
                    style: .continuous
                )
                .stroke(
                    borderColor,
                    lineWidth: 1
                )
            }
    }

    @ViewBuilder private var chipContent: some View {
        if let systemImage {
            Label {
                text
            } icon: {
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
            }
        } else {
            text
        }
    }

    private var backgroundColor: Color {
        foregroundColor.opacity(fillOpacity)
    }

    private var borderColor: Color {
        foregroundColor.opacity(borderOpacity)
    }

    private var borderOpacity: Double {
        if tone == .neutral {
            BatchStatusChipDefaults.neutralBorderOpacity
        } else {
            BatchStatusChipDefaults.emphasizedBorderOpacity
        }
    }

    private var fillOpacity: Double {
        if tone == .neutral {
            BatchStatusChipDefaults.neutralFillOpacity
        } else {
            BatchStatusChipDefaults.emphasizedFillOpacity
        }
    }

    private var foregroundColor: Color {
        switch tone {
        case .accent:
            .accentColor
        case .neutral:
            .secondary
        case .success:
            .green
        case .warning:
            .orange
        }
    }
}

private enum BatchStatusChipDefaults {
    static let emphasizedBorderOpacity = 0.14
    static let emphasizedFillOpacity = 0.08
    static let neutralBorderOpacity = 0.10
    static let neutralFillOpacity = 0.06
}

extension BatchStatusChip {
    init(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        tone: Tone = .neutral
    ) {
        self.systemImage = systemImage
        self.text = Text(title)
        self.tone = tone
    }

    init(
        text: Text,
        systemImage: String? = nil,
        tone: Tone = .neutral
    ) {
        self.systemImage = systemImage
        self.text = text
        self.tone = tone
    }
}
// swiftlint:enable one_declaration_per_file file_types_order
