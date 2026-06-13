import SwiftUI

struct BatchImageImportActionButtonsView: View {
    let importedImageCount: Int
    let reviewSelection: (() -> Void)?
    let clearSelection: () -> Void

    var body: some View {
        if importedImageCount > 0 {
            if let reviewSelection {
                Button {
                    reviewSelection()
                } label: {
                    Label("Review", systemImage: "eye")
                }
                .buttonStyle(.bordered)
            }

            Button {
                clearSelection()
            } label: {
                Label("Clear", systemImage: "xmark.circle")
            }
            .buttonStyle(.bordered)
        }
    }
}
