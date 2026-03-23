//
//  ContentView.swift
//  Liet
//
//  Created by Hiromu Nakano on 2026/03/23.
//

import LietLibrary
import SwiftUI

struct ContentView: View {
    private enum Layout {
        static let contentSpacing = 16.0
        static let contentPadding = 24.0
    }

    var body: some View {
        NavigationStack {
            VStack(
                alignment: .leading,
                spacing: Layout.contentSpacing
            ) {
                Text("Liet")
                    .font(.largeTitle.weight(.semibold))
                Text("Shared library scaffold is ready.")
                    .font(.headline)
                Text("App Group")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(AppGroup.id)
                    .font(.footnote.monospaced())
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(Layout.contentPadding)
            .navigationTitle("Liet")
        }
    }
}

#Preview {
    ContentView()
}
