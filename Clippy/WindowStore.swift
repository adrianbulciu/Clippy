//
//  WindowStore.swift
//  Clippy
//
//  Created by Adrian Bulciu on 30.12.2025.
//

import SwiftUI

@MainActor
final class WindowStore {
    static let shared = WindowStore()
    weak var clipsWindow: NSWindow?
}

struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
    }
}
