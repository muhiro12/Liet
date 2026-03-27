import Foundation

extension BatchImagePreferencesState {
    var validatedNaming: BatchImageNaming? {
        let naming: BatchImageNaming = .init(
            template: namingTemplate,
            customPrefix: customNamingPrefixText,
            numberingStyle: numberingStyle
        )

        guard naming.isValid else {
            return nil
        }

        return naming
    }
}
