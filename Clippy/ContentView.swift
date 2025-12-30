//
//  ContentView.swift
//  Clippy
//
//  Created by Adrian Bulciu on 25.12.2025.
//

import SwiftUI
import Cocoa

struct ContentView: View {
    @StateObject private var viewModel = ClipboardViewModel()
    @StateObject var permissionManager = PermissionManager()
    @State var showPermissionAlert = false
    @State private var searchText: String = ""
    @State private var selection: String?
    
    enum FocusTarget {
        case search
        case list
    }

    @FocusState private var focus: FocusTarget?
    
    var filteredClips: [String] {
        searchText.isEmpty
            ? viewModel.clips
            : viewModel.clips.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
    }
    
    var body: some View {
        VStack {
            TextField("Search Clips", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing, .top], 12)
                .focused($focus, equals: .search)
                .onKeyPress(.downArrow) {
                    moveFocusToList()
                    return .handled
                }
            List(filteredClips, id: \.self, selection: $selection) { text in
                ClipView(text: text)
                    .listRowSeparator(.hidden)
                    .tag(text)
                    .onTapGesture {
                        selection = text
                        pasteSelectedClip()
                    }
            }
            .focusable()
            .focused($focus, equals: .list)
            .listStyle(.plain)
            .padding(.vertical, 5)
            .onKeyPress(.upArrow) {
                if selection == filteredClips.first {
                    focus = .search
                    return .handled
                }
                return .ignored
            }
        }
        .navigationTitle("Clips")
        .frame(width: 400, height: 500)
        .onAppear {
            DispatchQueue.main.async {
                focus = .search
            }
        }
        .onKeyPress { event in
            if event.key == "f" && event.modifiers.contains(.command) {
                focus = .search
                return .handled
            }
            
            return .ignored
        }
        .onKeyPress(.return) {
            pasteSelectedClip()
            return .handled
        }
        .onKeyPress(.escape) {
            NSApp.hide(nil)
            return .handled
        }
        .alert("Accessibility Permission Required", isPresented: $showPermissionAlert) {
            Button("Open System Settings") {
                permissionManager.openSystemSettings()
                showPermissionAlert = false
            }
            Button("Cancel", role: .cancel) {
                showPermissionAlert = false
            }
        } message: {
            Text("Clippy needs Accessibility permissions to paste into other apps automatically.")
        }
    }
    
    private func moveFocusToList() {
        guard !filteredClips.isEmpty else { return }
        
        selection = filteredClips.first
        focus = .list
    }
    
    private func pasteSelectedClip() {
        guard let text = selection else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        guard permissionManager.hasPermissionGranted() else {
            showPermissionAlert = true
            return
        }
        
        NSApp.hide(nil)
        sendPasteKeystroke()
    }
    
    private func sendPasteKeystroke() {
        let source = CGEventSource(stateID: .combinedSessionState)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let keyV: CGKeyCode = 9 // 'v'
            
            let keyDown = CGEvent(
                keyboardEventSource: source,
                virtualKey: keyV,
                keyDown: true
            )
            keyDown?.flags = .maskCommand
            
            let keyUp = CGEvent(
                keyboardEventSource: source,
                virtualKey: keyV,
                keyDown: false
            )
            keyUp?.flags = .maskCommand
            
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }
}

#Preview {
    ContentView()
}
