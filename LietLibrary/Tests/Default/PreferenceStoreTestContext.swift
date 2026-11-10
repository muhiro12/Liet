import Foundation
import MHPlatformCore

struct PreferenceStoreTestContext {
    let suiteName: String
    let userDefaults: UserDefaults
    let preferenceStore: MHPreferenceStore

    init() {
        suiteName = "LietLibraryTests.\(UUID().uuidString)"
        guard let isolatedDefaults = UserDefaults(
            suiteName: suiteName
        ) else {
            preconditionFailure("Failed to create isolated test defaults.")
        }

        userDefaults = isolatedDefaults
        preferenceStore = .init(
            userDefaults: isolatedDefaults
        )
    }

    func tearDown() {
        userDefaults.removePersistentDomain(
            forName: suiteName
        )
    }
}
