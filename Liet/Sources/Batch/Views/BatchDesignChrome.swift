// swiftlint:disable one_declaration_per_file file_types_order
import MHDesign
import SwiftUI
import UIKit

enum BatchDesignChrome {}
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
            .title2.weight(.semibold)
        case .sectionTitle:
            .title3.weight(.semibold)
        case .bodyStrong:
            .body.weight(.medium)
        case .supporting:
            .subheadline
        case .metadata:
            .footnote.weight(.medium)
        case .caption:
            .footnote.weight(.medium)
        }
    }
}
struct BatchSection<Content: View>: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let accessory: AnyView?
    private let content: Content
    private let supporting: Text?
    private let title: Text

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.group
        ) {
            BatchSectionHeader(
                title: title,
                supporting: supporting,
                accessory: accessory
            )

            content
                .batchSurfaceInset()
                .batchSurface()
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

private enum BatchChromeDefaults {
    static let minimumCompactHorizontalMargin: CGFloat = 8
    static let surfaceBorderLineWidth: CGFloat = 1
    static let surfaceBorderOpacity = 0.24
}

private struct BatchCueBlock<Content: View>: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let cueHeight: CGFloat
    let cueWidth: CGFloat
    let content: Content

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            Capsule()
                .fill(.tint)
                .frame(
                    width: cueWidth,
                    height: cueHeight
                )

            content
        }
    }

    init(
        cueWidth: CGFloat,
        cueHeight: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.cueHeight = cueHeight
        self.cueWidth = cueWidth
        self.content = content()
    }
}

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
            .frame(maxWidth: .infinity)
            .padding(
                .horizontal,
                isCompactWidth
                    ? designMetrics.layout.compactSurfaceInsetHorizontal
                    : designMetrics.spacing.group
            )
            .padding(
                .vertical,
                isCompactWidth
                    ? designMetrics.spacing.group
                    : designMetrics.spacing.section
            )
    }
}

private struct BatchResolvedScreenStyle {
    let contentSpacing: CGFloat
    let horizontalMargin: CGFloat
    let readableContentWidth: CGFloat?
    let verticalPadding: CGFloat
}

private struct BatchScreenModifier: ViewModifier {
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
        style: BatchResolvedScreenStyle,
        content: Content
    ) -> some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: style.contentSpacing
            ) {
                if title != nil || subtitle != nil {
                    BatchScreenTitleBlock(
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

    private func resolvedStyle(for width: CGFloat) -> BatchResolvedScreenStyle {
        let isCompactWidth = width < designMetrics.layout.compactWidthThreshold
        let usesNarrowFallback = width < designMetrics.layout.narrowWidthThreshold

        let horizontalMargin: CGFloat
        if isCompactWidth {
            if usesNarrowFallback {
                horizontalMargin = max(
                    BatchChromeDefaults.minimumCompactHorizontalMargin,
                    designMetrics.layout.compactScreenHorizontalMargin - designMetrics.spacing.inline
                )
            } else {
                horizontalMargin = designMetrics.layout.compactScreenHorizontalMargin
            }
        } else {
            horizontalMargin = designMetrics.layout.screenHorizontalMargin
        }

        return .init(
            contentSpacing: isCompactWidth
                ? designMetrics.layout.compactScreenContentSpacing
                : designMetrics.layout.screenContentSpacing,
            horizontalMargin: horizontalMargin,
            readableContentWidth: isCompactWidth
                ? nil
                : designMetrics.layout.readableContentWidth,
            verticalPadding: isCompactWidth
                ? designMetrics.layout.compactScreenVerticalPadding
                : designMetrics.layout.screenVerticalPadding
        )
    }
}

private struct BatchScreenTitleBlock: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let title: Text?
    let subtitle: Text?

    var body: some View {
        BatchCueBlock(
            cueWidth: designMetrics.layout.screenCueWidth,
            cueHeight: designMetrics.layout.screenCueHeight
        ) {
            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.group
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
}

private struct BatchSectionHeader: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let title: Text
    let supporting: Text?
    let accessory: AnyView?

    var body: some View {
        BatchCueBlock(
            cueWidth: designMetrics.layout.sectionCueWidth,
            cueHeight: designMetrics.layout.sectionCueHeight
        ) {
            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.inline
            ) {
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: designMetrics.layout.rowAccessorySpacing
                ) {
                    title
                        .batchTextStyle(.sectionTitle)

                    Spacer(
                        minLength: designMetrics.layout.rowAccessorySpacing
                    )

                    if let accessory {
                        accessory
                    }
                }

                if let supporting {
                    supporting
                        .batchTextStyle(
                            .supporting,
                            color: .secondary
                        )
                }
            }
        }
        .padding(.leading, designMetrics.spacing.inline)
    }
}

private struct BatchSurfaceInsetModifier: ViewModifier {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private var isCompactWidth: Bool {
        horizontalSizeClass == .compact
    }

    func body(content: Content) -> some View {
        content
            .padding(
                .horizontal,
                isCompactWidth
                    ? designMetrics.layout.compactSurfaceInsetHorizontal
                    : designMetrics.layout.surfaceInsetHorizontal
            )
            .padding(
                .vertical,
                isCompactWidth
                    ? designMetrics.layout.compactSurfaceInsetVertical
                    : designMetrics.layout.surfaceInsetVertical
            )
    }
}

private struct BatchSurfaceModifier: ViewModifier {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(
            cornerRadius: designMetrics.radius.surface,
            style: .continuous
        )

        content
            .background(
                Color(uiColor: .secondarySystemBackground),
                in: shape
            )
            .overlay {
                shape.stroke(
                    Color(uiColor: .separator)
                        .opacity(BatchChromeDefaults.surfaceBorderOpacity),
                    lineWidth: BatchChromeDefaults.surfaceBorderLineWidth
                )
            }
    }
}
extension View {
    func batchEmptyStateLayout() -> some View {
        modifier(BatchEmptyStateLayoutModifier())
    }

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

    func batchSurface() -> some View {
        modifier(BatchSurfaceModifier())
    }

    func batchSurfaceInset() -> some View {
        modifier(BatchSurfaceInsetModifier())
    }

    func batchTextStyle(
        _ role: BatchTextRole,
        color: Color = .primary
    ) -> some View {
        font(role.font)
            .foregroundStyle(color)
    }
}
// swiftlint:enable one_declaration_per_file file_types_order
