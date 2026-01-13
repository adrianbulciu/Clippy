//
//  ContentView.swift
//  Clippy
//
//  Created by Adrian Bulciu on 25.12.2025.
//

import Cocoa
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: ClipboardViewModel
    @StateObject var permissionManager = PermissionManager()
    @Environment(\.scenePhase) private var scenePhase
    @State var showPermissionAlert = false
    @State private var searchText: String = ""
    @State private var selection: Clip?

    enum FocusTarget {
        case search
        case list
    }

    @FocusState private var focus: FocusTarget?

    var filteredClips: [Clip] {
        searchText.isEmpty
            ? viewModel.clips
            : viewModel.clips.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
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
            if !filteredClips.isEmpty {
                Button {
                    selection = nil
                    searchText = ""
                    viewModel.clips = []
                } label: {
                    Text("Clear list")
                        .frame(maxWidth: .infinity)
                }
                .padding(12)
            }
            ScrollViewReader { proxy in
                List(filteredClips, id: \.self, selection: $selection) { clip in
                    ClipView(clip: clip)
                        .listRowSeparator(.hidden)
                        .tag(clip.title)
                        .onTapGesture {
                            selection = clip
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
                .onChange(of: scenePhase) { old, newPhase in
                    if newPhase == .active {
                        searchText = ""
                        selection = nil
                        DispatchQueue.main.async {
                            focus = .search
                            guard let first = filteredClips.first else {
                                return
                            }
                            proxy.scrollTo(first, anchor: .top)
                        }
                    }
                }
            }
        }
        .navigationTitle("Clips")
        .frame(width: 400, height: 500)
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
        .alert(
            "Accessibility Permission Required",
            isPresented: $showPermissionAlert
        ) {
            Button("Open System Settings") {
                permissionManager.openSystemSettings()
                showPermissionAlert = false
            }
            Button("Cancel", role: .cancel) {
                showPermissionAlert = false
            }
        } message: {
            Text(
                "Clippy needs Accessibility permissions to paste into other apps automatically."
            )
        }
    }

    private func moveFocusToList() {
        guard !filteredClips.isEmpty else { return }

        selection = filteredClips.first
        focus = .list
    }

    private func pasteSelectedClip() {
        guard let selectedClip = selection else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        //        pasteboard.setString(selectedClip.content, forType: .string)
        switch selectedClip.type {
        case .directory, .file, .imagefile:
            //            if let data = Data(base64Encoded: selectedClip.content) {
            //                if let path = selectedClip.originalPath {
            //                    pasteboard.setString(path, forType: .fileURL)
            //                }
            //            }
            if let bookmark = selectedClip.fileBookmark {
                do {
                    var isStale = false
                    let url = try URL(
                        resolvingBookmarkData: bookmark,
                        options: [.withoutUI, .withSecurityScope],
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale
                    )

                    guard url.startAccessingSecurityScopedResource() else {
                        print("Failed to gain security-scoped access for paste")
                        fallthrough
                    }

                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    let urlData = url.dataRepresentation

//                    if let data = try? Data(contentsOf: url) {
                        pasteboard.setData(urlData, forType: .fileURL)
//                    }
                } catch {
                    print("Bookmark resolution failed: \(error)")
                }
            }
        case .image:
            if let data = Data(base64Encoded: selectedClip.content) {
                pasteboard.setData(data, forType: .png)
            }
        case .text, .other:
            pasteboard.setString(selectedClip.content, forType: .string)
        }

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
            let keyV: CGKeyCode = 9  // 'v'

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
        .environmentObject(ClipboardViewModel())
}
