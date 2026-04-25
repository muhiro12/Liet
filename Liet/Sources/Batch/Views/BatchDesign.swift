import SwiftUI

enum BatchDesign {
    enum FeatureChooser {
        static let featureIconWidth = 32.0
    }

    enum Grid {
        static let thumbnailColumnMinimum = 130.0
    }

    enum ImportedTile {
        static let detailLineLimit = 3
        static let imageHeight = 96.0
        static let textSpacing = 4.0
    }

    enum ProcessedTile {
        static let detailLineLimit = 2
        static let filenameSpacing = 6.0
        static let imageHeight = 112.0
        static let textSpacing = 6.0
    }

    enum TransparencyPreview {
        static let fullscreenTileSize = 18.0
        static let thumbnailTileSize = 6.0
    }

    enum Fullscreen {
        static let closeButtonBackgroundOpacity = 0.5
        static let closeButtonImageSize = 22.0
        static let closeButtonPadding = 10.0
        static let closeButtonTopPadding = 12.0
        static let contentHorizontalPadding = 16.0
        static let contentVerticalSpacing = 16.0
        static let detailSpacing = 4.0
        static let maximumZoomScale = 4.0
        static let metadataBottomPadding = 20.0
        static let metadataHorizontalPadding = 20.0
        static let metadataLineLimit = 2
        static let secondaryTextOpacity = 0.72
    }

    enum Animation {
        static let processingSpringBlendDuration = 0.12
        static let processingSpringDampingFraction = 0.88
        static let processingSpringResponse = 0.42
        static let sectionTransitionScale = 0.98
    }

    enum Step {
        static let `import` = 1
        static let process = 3
        static let processing = 2
    }
}
