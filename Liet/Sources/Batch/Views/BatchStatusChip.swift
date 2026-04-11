import SwiftUI

struct BatchStatusChip: View {
    enum Tone: Equatable {
        case accent
        case neutral
        case success
        case warning
    }

    private let systemImage: String?
    private let text: Text
    private let tone: Tone

    var body: some View {
        chipContent
            .font(.footnote.weight(.medium))
            .foregroundStyle(foregroundColor)
            .lineLimit(1)
            .fixedSize(horizontal: false, vertical: true)
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
