import SwiftUI
import TipKit

struct ResizeMethodTip: Tip {
    @Parameter static var hasConfiguredExactResizeMethod: Bool = false

    var title: Text {
        Text("Choose how the frame fits")
    }

    var message: Text? {
        Text(
            """
            Stretch fills the frame. Contain keeps the whole image. Crop trims from the center.
            """
        )
    }

    var image: Image? {
        Image(systemName: "aspectratio")
    }

    var rules: [Rule] {
        #Rule(Self.$hasConfiguredExactResizeMethod) { hasConfiguredExactResizeMethod in
            hasConfiguredExactResizeMethod == false
        }
        #Rule(RunProcessingTip.$hasCompletedProcessStep) { hasCompletedProcessStep in
            hasCompletedProcessStep == false
        }
    }
}
