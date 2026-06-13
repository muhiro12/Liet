import SwiftUI

extension BatchBackgroundRemovalHomeView {
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
