//
//  MenuBarView.swift
//  Clippy
//
//  Created by Adrian Bulciu on 27.12.2025.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    @StateObject private var viewModel = ClipboardViewModel()

    var body: some View {
        VStack {
            Button("View Clips") {
                openWindow(id: "clips")
            }
            .keyboardShortcut("V")
            .buttonStyle(.borderless)
            
            Button("Settings") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",")
            .buttonStyle(.borderless)
            
            Button("Clear clips") {
                viewModel.clearClips()
            }
            .buttonStyle(.borderless)
            
            Button("Quit App") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("Q")
            .buttonStyle(.borderless)
        }
        .padding()
    }
}

#Preview {
    MenuBarView()
}
