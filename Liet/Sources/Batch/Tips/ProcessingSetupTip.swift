import SwiftUI
import TipKit

struct ProcessingSetupTip: Tip {
    var title: Text {
        Text("Choose one setting set")
    }

    var message: Text? {
        Text(
            """
            Choose Width, Height, or Exact size, then pick a quality level. \
            Exact size can contain or crop. PNG keeps its format. Originals stay untouched.
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
