//
//  AppFocusObserver.swift
//  Clippy
//
//  Created by Adrian Bulciu on 30.12.2025.
//

import SwiftUI

@MainActor
class AppFocusObserver: ObservableObject {
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    @objc private func appDidResignActive() {
        if let window = WindowStore.shared.clipsWindow, window.isVisible {
            window.orderOut(nil)
        }
    }
}
