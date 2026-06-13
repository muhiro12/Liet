import LietLibrary
import SwiftUI
import TipKit

struct BatchSettingsSourcePickerView: View {
    @Binding var selection: BatchImageSettingsSource

    let hasUserPresetSettings: Bool
    let processingSetupTip: ProcessingSetupTip

    var body: some View {
        Picker("Starting Point", selection: $selection) {
            Text("Last Used")
                .tag(BatchImageSettingsSource.lastUsed)
            Text("User Preset")
                .tag(BatchImageSettingsSource.userPreset)
                .disabled(!hasUserPresetSettings)
            Text("Custom")
                .tag(BatchImageSettingsSource.custom)
        }
        .pickerStyle(.segmented)
        .popoverTip(
            processingSetupTip,
            arrowEdge: .top
        )
    }
}
