import SwiftUI

struct BatchImageEmptyDetailView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    let backToSettings: (() -> Void)?

    var body: some View {
        ContentUnavailableView(
            "Select images to start",
            systemImage: "photo.on.rectangle.angled"
        )
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        }
    }
}
