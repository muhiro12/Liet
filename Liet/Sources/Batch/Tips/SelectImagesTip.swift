import SwiftUI
import TipKit

struct SelectImagesTip: Tip {
    @Parameter static var hasCompletedImportStep: Bool = false

    var title: Text {
        Text("Start with a batch")
    }

    var message: Text? {
        Text(
            """
            Pick one or more photos or image files. \
            Liet applies the same settings to every selected image in the current feature.
            """
        )
    }

    var image: Image? {
        Image(systemName: "photo.on.rectangle.angled")
    }

    var rules: [Rule] {
        #Rule(Self.$hasCompletedImportStep) { hasCompletedImportStep in
            hasCompletedImportStep == false
        }
    }
}
