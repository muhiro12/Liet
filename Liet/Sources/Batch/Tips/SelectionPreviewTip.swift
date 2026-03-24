import SwiftUI
import TipKit

struct SelectionPreviewTip: Tip {
    var title: Text {
        Text("Set size to preview outputs")
    }

    var message: Text? {
        Text("When the output size is valid, each thumbnail shows the projected result size.")
    }

    var image: Image? {
        Image(systemName: "eye")
    }

    var rules: [Rule] {
        #Rule(RunProcessingTip.$hasCompletedProcessStep) { hasCompletedProcessStep in
            hasCompletedProcessStep == false
        }
    }
}
