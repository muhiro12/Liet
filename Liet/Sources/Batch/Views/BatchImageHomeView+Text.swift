import SwiftUI

extension BatchImageHomeView {
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
        for alert: BatchImageHomeModel.AlertState
    ) -> Text {
        switch alert {
        case .invalidResizeSize:
            Text("Enter valid width and height values.")
        case .importSelectionFailed:
            Text("Couldn't import the selected images.")
        case .processSelectionFailed:
            Text("Couldn't process the selected images.")
        }
    }
}
