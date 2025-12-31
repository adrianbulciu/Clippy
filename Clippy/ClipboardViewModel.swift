//
//  ClipboardViewModel.swift
//  Clippy
//
//  Created by Adrian Bulciu on 30.12.2025.
//

import SwiftUI
import Combine

class ClipboardViewModel: ObservableObject {
    @Published var clipboardText: String = ""
    @AppStorage("clips") private var clipsData: Data = Data()
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
}
