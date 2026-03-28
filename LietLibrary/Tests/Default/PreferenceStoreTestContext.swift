import Foundation
import MHPlatformCore

struct PreferenceStoreTestContext {
    let suiteName: String
    let userDefaults: UserDefaults
    let preferenceStore: MHPreferenceStore

    init() {
        suiteName = "LietLibraryTests.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(
            suiteName: suiteName
        ) else {
            preconditionFailure("Failed to create isolated test defaults.")
        }

        self.userDefaults = userDefaults
        preferenceStore = .init(
            userDefaults: userDefaults
        )
    }

    func tearDown() {
        userDefaults.removePersistentDomain(
            forName: suiteName
        )
    }
}
