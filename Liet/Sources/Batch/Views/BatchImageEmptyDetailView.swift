import SwiftUI

struct BatchImageEmptyDetailView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    let backToSettings: (() -> Void)?

    var body: some View {
        ContentUnavailableView(
            "Select images to start",
            systemImage: "photo.on.rectangle.angled",
            description: Text(
                """
                Import one or more photos from the sidebar, then review the selection \
                or process the batch.
                """
            )
        )
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let backToSettings,
               horizontalSizeClass == .compact {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back to Settings") {
                        backToSettings()
                    }
                }
            }
        }
    }
}
