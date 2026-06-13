import SwiftUI

extension BatchImageHomeView {
    func alertTitle(
        for alert: BatchImageHomeModel.AlertState
    ) -> Text {
        switch alert {
        case .invalidResizeSize:
            Text("Invalid Settings")
        case .importSelectionFailed:
            Text("Import Failed")
        case .processSelectionFailed:
            Text("Processing Failed")
        }
    }

    func alertText(
        for alert: BatchImageHomeModel.AlertState
    ) -> Text {
        switch alert {
        case .invalidResizeSize:
            Text("Enter valid output size and file naming values.")
        case .importSelectionFailed:
            Text("Couldn't import the selected images.")
        case .processSelectionFailed:
            Text("Couldn't process the selected images.")
        }
    }
}
