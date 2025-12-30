//
//  AppState.swift
//  Clippy
//
//  Created by Adrian Bulciu on 30.12.2025.
//

import SwiftUI
import KeyboardShortcuts

@MainActor
@Observable
final class AppState {
    public var openWindowCallback: () -> Void
    
    init(openWindowCallback: @escaping () -> Void) {
        self.openWindowCallback = openWindowCallback
        
        KeyboardShortcuts.onKeyUp(for: .openClipsShortcutKeybind) { [weak self] in
            self?.openWindowCallback()
        }
    }
}
