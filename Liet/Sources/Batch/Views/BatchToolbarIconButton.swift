import SwiftUI

struct BatchToolbarIconButton: View {
    let systemImage: String
    let accessibilityLabel: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
        }
        .accessibilityLabel(Text(accessibilityLabel))
    }
}
