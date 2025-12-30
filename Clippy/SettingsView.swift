//
//  SettingsView.swift
//  Clippy
//
//  Created by Adrian Bulciu on 27.12.2025.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @AppStorage("clipsHistoryLimit") var clipsHistoryLimit = 50
    @StateObject private var permissionManager = PermissionManager()
    
    var body: some View {
        VStack {
            Image("clippy_settings")
            Form {
                Picker("Clips history limit: ", selection: $clipsHistoryLimit) {
                    ForEach(Array(stride(from: 50, through: 500, by: 50)), id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                    }
                }
                .pickerStyle(.automatic)
                KeyboardShortcuts.Recorder("Open clips shortcut: ", name: .openClipsShortcutKeybind)
                
                if permissionManager.hasPermissionGranted() {
                    LabeledContent("Accessibility Permissions", value: "Granted")
                }
                else {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        Link("Grant accessibility permissions", destination: url)
                    }
                }
            }
            .formStyle(.grouped)
            
        }
        .frame(width: 350, height: 250)
    }
}

#Preview {
    SettingsView()
}
