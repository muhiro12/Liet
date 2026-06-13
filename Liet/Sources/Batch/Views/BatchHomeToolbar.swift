import SwiftUI

struct BatchHomeToolbar: ToolbarContent {
    let backToChooser: (() -> Void)?
    let replayTips: () -> Void

    var body: some ToolbarContent {
        if let backToChooser {
            ToolbarItem(placement: .topBarLeading) {
                BatchToolbarIconButton(
                    systemImage: "square.grid.2x2",
                    accessibilityLabel: "Choose Feature"
                ) {
                    backToChooser()
                }
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            BatchToolbarIconButton(
                systemImage: "questionmark.circle",
                accessibilityLabel: "Show Tips Again"
            ) {
                replayTips()
            }
        }
    }
}
