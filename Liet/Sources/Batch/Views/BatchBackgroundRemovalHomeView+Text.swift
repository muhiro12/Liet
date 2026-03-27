import SwiftUI

extension BatchBackgroundRemovalHomeView {
    func selectedImageCountText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("1 image selected")
        } else {
            Text("\(count) images selected")
        }
    }

    func importFailureText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("1 image couldn't be loaded.")
        } else {
            Text("\(count) images couldn't be loaded.")
        }
    }

    func alertText(
        for alert: BatchBackgroundRemovalHomeModel.AlertState
    ) -> Text {
        switch alert {
        case .invalidConfiguration:
            Text("Enter valid file naming values.")
        case .importSelectionFailed:
            Text("Couldn't import the selected images.")
        case .processSelectionFailed:
            Text("Couldn't remove the background from the selected images.")
        }
    }
}
