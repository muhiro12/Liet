//
//  LietApp.swift
//  Liet
//
//  Created by Hiromu Nakano on 2026/03/23.
//

import LietLibrary
import MHPlatform
import SwiftUI

@main
struct LietApp: App {
    @State private var bootstrap = MHAppRuntimeBootstrap(
        configuration: .init(
            preferencesSuiteName: AppGroup.id,
            showsLicenses: false
        )
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .mhAppRuntimeBootstrap(bootstrap)
        }
    }

    init() {
        BatchImageTipSupport.configureIfNeeded()
    }
}
