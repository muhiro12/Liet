import MHDesign
import SwiftUI

private struct BatchEmptyStateLayoutModifier: ViewModifier {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private var isCompactWidth: Bool {
        horizontalSizeClass == .compact
    }

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(
                .horizontal,
                isCompactWidth
                    ? designMetrics.layout.screen.compactContentInsetHorizontal
                    : designMetrics.layout.screen.contentInsetHorizontal
            )
            .padding(
                .vertical,
                isCompactWidth
                    ? designMetrics.spacing.content
                    : designMetrics.spacing.section
            )
    }
}

extension View {
    func batchEmptyStateLayout() -> some View {
        modifier(BatchEmptyStateLayoutModifier())
    }
}
