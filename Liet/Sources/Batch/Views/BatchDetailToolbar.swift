import SwiftUI

struct BatchDetailToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    let backToSettings: (() -> Void)?
    let replayTips: () -> Void

    var body: some ToolbarContent {
        if let backToSettings,
           horizontalSizeClass == .compact {
            ToolbarItem(placement: .topBarLeading) {
                BatchToolbarIconButton(
                    systemImage: "sidebar.leading",
                    accessibilityLabel: "Back to Settings"
                ) {
                    backToSettings()
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
