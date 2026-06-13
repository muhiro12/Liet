import MHDesign
import SwiftUI

struct BatchSettingsSection<Content: View>: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let content: () -> Content
    private let title: LocalizedStringKey

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            Text(title)
                .batchTextStyle(.bodyStrong)

            content()
        }
    }

    init(
        title: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.title = title
    }
}
