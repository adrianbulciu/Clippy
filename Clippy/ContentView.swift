//
//  ContentView.swift
//  Clippy
//
//  Created by Adrian Bulciu on 25.12.2025.
//

import SwiftUI

struct ContentView: View {
    var clips: [Clip] = [
        Clip(id: 1, text: "foo"),
        Clip(id: 2, text: "bar"),
        Clip(id: 3, text: "baz")
    ]
    
    var body: some View {
        VStack {
            List(clips) { clip in
                ClipView(clip: clip)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .padding([.top, .bottom], 5)
            Divider()
            HStack {
                Button("Clear") {
                    
                }
                Button("Settings") {
                    
                }
                Button("Quit App") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding()
        }
        .frame(width: 250, height: 300)
    }
}

#Preview {
    ContentView()
}
