//
//  ClippyApp.swift
//  Clippy
//
//  Created by Adrian Bulciu on 25.12.2025.
//

import SwiftUI

@main
struct ClippyApp: App {
    @StateObject var viewModel = ClipboardViewModel()
    @StateObject private var focusObserver = AppFocusObserver()
    @State private var appState = AppState(openWindowCallback: {})
    @Environment(\.openWindow) private var openWindow
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        MenuBarExtra("Clippy", image: "clippy_menubar_icon") {
            MenuBarView()
                .environmentObject(viewModel)
        }
        .menuBarExtraStyle(.menu)
        .onChange(of: scenePhase, initial: true) { oldValue, newValue in
            appState.openWindowCallback = {
                if let window = WindowStore.shared.clipsWindow, window.isVisible {
                    window.orderOut(nil)
                } else {
                    openWindow(id: "clips")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NSApp.activate(ignoringOtherApps: true)
                        NSRunningApplication.current.activate(options: [.activateAllWindows])
                    }
                }
            }
        }
        
        Window("Clips", id: "clips") {
            ContentView()
                .environmentObject(viewModel)
                .background(
                    WindowAccessor { window in
                        guard let window else { return }

                        WindowStore.shared.clipsWindow = window

                        window.level = .floating

                        DispatchQueue.main.async {
                            guard let screen = window.screen ?? NSScreen.main else { return }

                            let size = window.frame.size
                            let frame = screen.visibleFrame

                            window.setFrameOrigin(
                                CGPoint(
                                    x: frame.midX - size.width / 2,
                                    y: frame.minY + 50
                                )
                            )
                        }
                    }
                    .frame(width: 0, height: 0)
                )
        }
        .windowResizability(.contentSize)
        
        Window("Settings", id: "settings") {
            SettingsView()
        }
        .windowLevel(.floating)
        .windowResizability(.contentSize)

    }
}
