import MHDesign
import SwiftUI

struct BatchSection<Content: View>: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let accessory: AnyView?
    private let content: Content
    private let supporting: Text?
    private let title: Text

    var body: some View {
        GroupBox {
            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.control
            ) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            HStack(
                alignment: .firstTextBaseline,
                spacing: designMetrics.spacing.control
            ) {
                VStack(
                    alignment: .leading,
                    spacing: designMetrics.spacing.inline
                ) {
                    title
                        .batchTextStyle(.sectionTitle)

                    if let supporting {
                        supporting
                            .batchTextStyle(
                                .supporting,
                                color: .secondary
                            )
                    }
                }

                Spacer(
                    minLength: designMetrics.spacing.control
                )

                if let accessory {
                    accessory
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    init(
        title: Text,
        supporting: Text? = nil,
        accessory: AnyView? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.accessory = accessory
        self.content = content()
        self.supporting = supporting
        self.title = title
    }
}
