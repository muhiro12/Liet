import LietLibrary
import MHDesign
import SwiftUI

struct BatchFileNamingSectionView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var namingTemplate: BatchImageNamingTemplate
    @Binding var customNamingPrefix: String
    @Binding var numberingStyle: BatchImageNumberingStyle

    let showsCustomNamingPrefixField: Bool
    let hasValidNaming: Bool

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.control
        ) {
            BatchNamingTemplatePickerView(
                namingTemplate: $namingTemplate
            )

            BatchCustomNamingPrefixView(
                customNamingPrefix: $customNamingPrefix,
                showsCustomNamingPrefixField: showsCustomNamingPrefixField,
                hasValidNaming: hasValidNaming
            )

            BatchNumberingStylePickerView(
                numberingStyle: $numberingStyle
            )
        }
    }
}
