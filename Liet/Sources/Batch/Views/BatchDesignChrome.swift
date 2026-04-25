// swiftlint:disable one_declaration_per_file file_types_order
import MHDesign
import SwiftUI
import UIKit

enum BatchDesignChrome {}

enum BatchImagePreviewBackground {
    static func patternColor(
        tileSize: CGFloat
    ) -> UIColor {
        UIColor(
            patternImage: patternImage(
                tileSize: tileSize
            )
        )
    }
}

struct BatchImagePreviewSurface: View {
    let image: UIImage
    let showsTransparencyBackground: Bool
    let tileSize: CGFloat
    let contentMode: ContentMode

    var body: some View {
        ZStack {
            if showsTransparencyBackground {
                Color(
                    uiColor: BatchImagePreviewBackground.patternColor(
                        tileSize: tileSize
                    )
                )
            }

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .accessibilityHidden(true)
        }
        .clipped()
    }
}

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
            .title3.weight(.semibold)
        case .sectionTitle:
            .headline
        case .bodyStrong:
            .subheadline.weight(.semibold)
        case .supporting:
            .subheadline
        case .metadata:
            .footnote.weight(.medium)
        case .caption:
            .footnote
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
                spacing: designMetrics.layout.rowAccessorySpacing
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
                    minLength: designMetrics.layout.rowAccessorySpacing
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

private enum BatchChromeDefaults {
    static let minimumCompactHorizontalMargin: CGFloat = 8
}

private extension BatchImagePreviewBackground {
    static let colorAlpha: CGFloat = 1
    static let darkWhiteComponent: CGFloat = 0.82
    static let lightWhiteComponent: CGFloat = 0.94
    static let patternDimensionMultiplier: CGFloat = 2
    static let lightColor = UIColor(white: lightWhiteComponent, alpha: colorAlpha)
    static let darkColor = UIColor(white: darkWhiteComponent, alpha: colorAlpha)

    static func patternImage(
        tileSize: CGFloat
    ) -> UIImage {
        let resolvedTileSize = max(1, tileSize)
        let patternSize = CGSize(
            width: resolvedTileSize * patternDimensionMultiplier,
            height: resolvedTileSize * patternDimensionMultiplier
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true

        return UIGraphicsImageRenderer(
            size: patternSize,
            format: format
        ).image { rendererContext in
            lightColor.setFill()
            rendererContext.fill(
                CGRect(
                    origin: .zero,
                    size: patternSize
                )
            )

            darkColor.setFill()
            rendererContext.fill(
                CGRect(
                    x: 0,
                    y: 0,
                    width: resolvedTileSize,
                    height: resolvedTileSize
                )
            )
            rendererContext.fill(
                CGRect(
                    x: resolvedTileSize,
                    y: resolvedTileSize,
                    width: resolvedTileSize,
                    height: resolvedTileSize
                )
            )
        }
    }
}

extension CGImage {
    var batchHasAlphaChannel: Bool {
        switch alphaInfo {
        case .alphaOnly,
             .first,
             .last,
             .premultipliedFirst,
             .premultipliedLast:
            true
        case .none,
             .noneSkipFirst,
             .noneSkipLast:
            false
        @unknown default:
            false
        }
    }
}

extension UIImage {
    var batchHasAlphaChannel: Bool {
        cgImage?.batchHasAlphaChannel ?? false
    }
}

private struct BatchResolvedScreenStyle {
    let contentSpacing: CGFloat
    let horizontalMargin: CGFloat
    let readableContentWidth: CGFloat?
    let verticalPadding: CGFloat
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(
                .horizontal,
                isCompactWidth
                    ? designMetrics.layout.compactScreenHorizontalMargin
                    : designMetrics.layout.screenHorizontalMargin
            )
            .padding(
                .vertical,
                isCompactWidth
                    ? designMetrics.spacing.group
                    : designMetrics.spacing.section
            )
    }
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
                    BatchScreenHeader(
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

private struct BatchScreenHeader: View {
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

    func batchTextStyle(
        _ role: BatchTextRole,
        color: Color = .primary
    ) -> some View {
        font(role.font)
            .foregroundStyle(color)
    }
}
// swiftlint:enable one_declaration_per_file file_types_order
