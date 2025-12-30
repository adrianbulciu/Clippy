//
//  PermissionManager.swift
//  Clippy
//
//  Created by Adrian Bulciu on 30.12.2025.
//

import SwiftUI

@MainActor
class PermissionManager: ObservableObject {
    func hasPermissionGranted() -> Bool {
        let trusted = AXIsProcessTrusted()
        return trusted
    }
    
    func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
