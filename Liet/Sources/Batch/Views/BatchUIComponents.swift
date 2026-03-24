import SwiftUI

struct BatchStatusChip: View {
    enum Tone {
        case accent
        case neutral
        case success
        case warning
    }

    private enum Layout {
        static let borderOpacity = 0.14
        static let horizontalPadding = 10.0
        static let verticalPadding = 6.0
    }

    private let systemImage: String?
    private let text: Text
    private let tone: Tone

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

    var body: some View {
        chipContent()
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
}

private extension BatchStatusChip {
    @ViewBuilder
    func chipContent() -> some View {
        if let systemImage {
            Label {
                text
            } icon: {
                Image(systemName: systemImage)
            }
        } else {
            text
        }
    }

    var backgroundColor: Color {
        switch tone {
        case .accent:
            Color.accentColor.opacity(0.14)
        case .neutral:
            Color(uiColor: .secondarySystemFill)
        case .success:
            Color.green.opacity(0.14)
        case .warning:
            Color.orange.opacity(0.16)
        }
    }

    var borderColor: Color {
        switch tone {
        case .accent:
            Color.accentColor.opacity(Layout.borderOpacity)
        case .neutral:
            Color.primary.opacity(0.08)
        case .success:
            Color.green.opacity(Layout.borderOpacity)
        case .warning:
            Color.orange.opacity(Layout.borderOpacity)
        }
    }
}

struct BatchToolbarIconButton: View {
    let systemImage: String
    let accessibilityLabel: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
        }
        .accessibilityLabel(Text(accessibilityLabel))
    }
}
