import MHDesign
import SwiftUI

struct BatchStepSection<Content: View>: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let content: () -> Content
    private let number: Int
    private let title: LocalizedStringKey

    var body: some View {
        BatchSection(
            title: Text(title),
            accessory: AnyView(
                BatchStatusChip(
                    text: Text("Step \(number)"),
                    tone: .accent
                )
            )
        ) {
            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.control
            ) {
                content()
            }
        }
    }

    init(
        number: Int,
        title: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.number = number
        self.title = title
    }
}
