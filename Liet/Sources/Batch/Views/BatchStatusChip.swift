import SwiftUI

struct BatchStatusChip: View {
    enum Tone {
        case accent
        case neutral
        case success
        case warning
    }

    private enum Layout {
        static let accentBackgroundOpacity = 0.14
        static let borderOpacity = 0.14
        static let horizontalPadding = 10.0
        static let neutralBorderOpacity = 0.08
        static let verticalPadding = 6.0
        static let warningBackgroundOpacity = 0.16
    }

    private let systemImage: String?
    private let text: Text
    private let tone: Tone

    var body: some View {
        chipContent
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.verticalPadding)
            .background(
                Capsule(style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(
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
        switch tone {
        case .accent:
            Color.accentColor.opacity(Layout.accentBackgroundOpacity)
        case .neutral:
            Color(uiColor: .secondarySystemFill)
        case .success:
            Color.green.opacity(Layout.borderOpacity)
        case .warning:
            Color.orange.opacity(Layout.warningBackgroundOpacity)
        }
    }

    private var borderColor: Color {
        switch tone {
        case .accent:
            Color.accentColor.opacity(Layout.borderOpacity)
        case .neutral:
            Color.primary.opacity(Layout.neutralBorderOpacity)
        case .success:
            Color.green.opacity(Layout.borderOpacity)
        case .warning:
            Color.orange.opacity(Layout.borderOpacity)
        }
    }
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
