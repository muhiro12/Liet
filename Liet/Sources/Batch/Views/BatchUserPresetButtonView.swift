import SwiftUI
import TipKit

struct BatchUserPresetButtonView: View {
    let canSavePreset: Bool
    let userPresetTip: UserPresetTip
    let savePreset: () -> Void

    var body: some View {
        Button {
            savePreset()
        } label: {
            Label("Save Preset", systemImage: "bookmark")
        }
        .buttonStyle(.bordered)
        .disabled(!canSavePreset)
        .popoverTip(
            userPresetTip,
            arrowEdge: .top
        )
    }
}
