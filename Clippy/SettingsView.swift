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
    
    var body: some View {
        VStack {
            Form {
                Picker("Clips history limit", selection: $clipsHistoryLimit) {
                    ForEach(Array(stride(from: 50, through: 500, by: 50)), id: \.self) { value in
                        Text("\(value)")
                    }
                }
                .pickerStyle(.automatic)
                KeyboardShortcuts.Recorder("Open clips shortcut: ", name: .openClipsShortcutKeybind)
            }
        }
        .frame(width: 300, height: 200)
    }
}

#Preview {
    SettingsView()
}
