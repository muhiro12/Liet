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
    @State private var assembly = LietAppAssembly.live()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .mhAppRuntimeBootstrap(assembly.bootstrap)
        }
    }

    init() {
        BatchImageTipSupport.configureIfNeeded()
    }
}
