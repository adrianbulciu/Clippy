//
//  ClippyApp.swift
//  Clippy
//
//  Created by Adrian Bulciu on 25.12.2025.
//

import SwiftUI

@main
struct ClippyApp: App {
    var body: some Scene {
        MenuBarExtra("Clippy", systemImage: "hammer") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
