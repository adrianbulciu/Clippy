//
//  ClippyApp.swift
//  Clippy
//
//  Created by Adrian Bulciu on 25.12.2025.
//

import SwiftUI
import AppKit
import Combine
import KeyboardShortcuts
import ApplicationServices

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

class ClipboardViewModel: ObservableObject {
    @Published var clipboardText: String = ""
    @AppStorage("clips") var clipsData: Data = Data()
    @AppStorage("clipsHistoryLimit") var clipsHistoryLimit = 50
    private var cancellable: AnyCancellable?
    
    var clips: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: clipsData)) ?? []
        }
        set {
            objectWillChange.send()
            clipsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    init() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .map { _ in
                guard let items = NSPasteboard.general.pasteboardItems else { return "" }
                
                if let string = items.first?.string(forType: .string) {
                    return string
                }
                
                return ""
            }
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self, !newValue.isEmpty else { return }

                self.clipboardText = newValue
                
                if self.clips.count == self.clipsHistoryLimit {
                    _ = self.clips.popLast()
                }

                if !self.clips.contains(newValue) {
                    self.clips.insert(newValue, at: 0)
                }
            }
    }
    
    func clearClips() -> Void {
        self.clips.removeAll()
    }
}

extension KeyboardShortcuts.Name {
    static let openClipsShortcutKeybind = Self("openClipsShortcutKeybind")
}

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
