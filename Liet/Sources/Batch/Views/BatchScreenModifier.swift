import MHDesign
import SwiftUI
import UIKit

private struct BatchScreenModifier: ViewModifier {
    private enum Defaults {
        static let minimumCompactHorizontalMargin: CGFloat = 8
        static let narrowWidthThreshold: CGFloat = 360
    }

    private struct ResolvedStyle {
        let contentSpacing: CGFloat
        let horizontalMargin: CGFloat
        let readableContentWidth: CGFloat?
        let verticalPadding: CGFloat
    }

    private struct Header: View {
        @Environment(\.mhDesignMetrics)
        private var designMetrics

        let title: Text?
        let subtitle: Text?

        var body: some View {
            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.inline
            ) {
                if let title {
                    title
                        .batchTextStyle(.screenTitle)
                }

                if let subtitle {
                    subtitle
                        .batchTextStyle(
                            .supporting,
                            color: .secondary
                        )
                }
            }
        }
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let subtitle: Text?
    let title: Text?

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            screenContent(
                style: resolvedStyle(for: proxy.size.width),
                content: content
            )
        }
    }

    private func screenContent(
        style: ResolvedStyle,
        content: Content
    ) -> some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: style.contentSpacing
            ) {
                if title != nil || subtitle != nil {
                    Header(
                        title: title,
                        subtitle: subtitle
                    )
                }

                content
            }
            .frame(
                maxWidth: style.readableContentWidth,
                alignment: .leading
            )
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )
            .padding(
                .horizontal,
                style.horizontalMargin
            )
            .padding(
                .vertical,
                style.verticalPadding
            )
        }
        .background(
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
        )
    }

    private func resolvedStyle(for width: CGFloat) -> ResolvedStyle {
        let isCompactWidth = width < designMetrics.layout.compactWidthThreshold
        let usesNarrowFallback = width < Defaults.narrowWidthThreshold

        let horizontalMargin: CGFloat
        if isCompactWidth {
            if usesNarrowFallback {
                horizontalMargin = max(
                    Defaults.minimumCompactHorizontalMargin,
                    designMetrics.layout.screen.compactContentInsetHorizontal - designMetrics.spacing.inline
                )
            } else {
                horizontalMargin = designMetrics.layout.screen.compactContentInsetHorizontal
            }
        } else {
            horizontalMargin = designMetrics.layout.screen.contentInsetHorizontal
        }

        return .init(
            contentSpacing: isCompactWidth
                ? designMetrics.layout.screen.compactContentSpacing
                : designMetrics.layout.screen.contentSpacing,
            horizontalMargin: horizontalMargin,
            readableContentWidth: isCompactWidth
                ? nil
                : designMetrics.layout.readableContentWidth,
            verticalPadding: isCompactWidth
                ? designMetrics.layout.screen.compactContentInsetVertical
                : designMetrics.layout.screen.contentInsetVertical
        )
    }
}

extension View {
    func batchScreen(
        title: Text? = nil,
        subtitle: Text? = nil
    ) -> some View {
        modifier(
            BatchScreenModifier(
                subtitle: subtitle,
                title: title
            )
        )
    }
}
