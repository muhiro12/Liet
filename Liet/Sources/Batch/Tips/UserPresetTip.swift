import SwiftUI
import TipKit

struct UserPresetTip: Tip {
    @Parameter static var hasSavedUserPreset: Bool = false

    var title: Text {
        Text("Save one reusable preset")
    }

    var message: Text? {
        Text("Save the current feature setup so you can start from it later.")
    }

    var image: Image? {
        Image(systemName: "bookmark")
    }

    var rules: [Rule] {
        #Rule(Self.$hasSavedUserPreset) { hasSavedUserPreset in
            hasSavedUserPreset == false
        }
        #Rule(RunProcessingTip.$hasCompletedProcessStep) { hasCompletedProcessStep in
            hasCompletedProcessStep == false
        }
    }
}
