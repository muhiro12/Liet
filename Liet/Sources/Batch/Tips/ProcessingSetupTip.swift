import SwiftUI
import TipKit

struct ProcessingSetupTip: Tip {
    var title: Text {
        Text("Choose a starting point")
    }

    var message: Text? {
        Text(
            """
            Start from Last Used or User Preset, then adjust size and compression. Editing any \
            value switches to Custom.
            """
        )
    }

    var image: Image? {
        Image(systemName: "slider.horizontal.3")
    }

    var rules: [Rule] {
        #Rule(RunProcessingTip.$hasCompletedProcessStep) { hasCompletedProcessStep in
            hasCompletedProcessStep == false
        }
    }
}
