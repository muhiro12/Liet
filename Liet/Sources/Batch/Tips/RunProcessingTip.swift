import SwiftUI
import TipKit

struct RunProcessingTip: Tip {
    @Parameter static var hasCompletedProcessStep: Bool = false

    var title: Text {
        Text("Process everything together")
    }

    var message: Text? {
        Text("When the settings look right, run one batch. Liet creates new files and never overwrites the originals.")
    }

    var image: Image? {
        Image(systemName: "play.circle")
    }

    var rules: [Rule] {
        #Rule(Self.$hasCompletedProcessStep) { hasCompletedProcessStep in
            hasCompletedProcessStep == false
        }
    }
}
