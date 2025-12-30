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
