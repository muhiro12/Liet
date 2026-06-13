import LietLibrary
import MHDesign
import SwiftUI

struct BatchNamingTemplatePickerView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var namingTemplate: BatchImageNamingTemplate

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            Text("Template")
                .batchTextStyle(.bodyStrong)

            Picker("Template", selection: $namingTemplate) {
                Text("IMG")
                    .tag(BatchImageNamingTemplate.img)
                Text("Processed")
                    .tag(BatchImageNamingTemplate.processed)
                Text("Custom")
                    .tag(BatchImageNamingTemplate.custom)
            }
            .pickerStyle(.segmented)
        }
    }
}
