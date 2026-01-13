//
//  ClipboardViewModel.swift
//  Clippy
//
//  Created by Adrian Bulciu on 30.12.2025.
//

import Combine
import SwiftUI

class ClipboardViewModel: ObservableObject {
    @Published var activeClip: Clip?
    private var clipsData: Data = Data()
    @AppStorage("clipsHistoryLimit") var clipsHistoryLimit = 50
    private var cancellable: AnyCancellable?
    private var lastChangeCount = 0

    //    private var cacheFolderURL: URL {
    //        let folder = FileManager.default
    //            .urls(for: .cachesDirectory, in: .userDomainMask)
    //            .first!
    //            .appendingPathComponent("Clippy")
    //
    //        try? FileManager.default.createDirectory(
    //            at: folder,
    //            withIntermediateDirectories: true
    //        )
    //
    //        return folder
    //    }

    private var clipsJsonUrl = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .first!
        .appendingPathComponent("Clippy")
        .appendingPathComponent("clips.json")

    var clips: [Clip] {
        get {
            if let data = try? Data(contentsOf: clipsJsonUrl) {
                return (try? JSONDecoder().decode([Clip].self, from: data))
                    ?? []
            } else {
                return []
            }
        }
        set {
            objectWillChange.send()

            // Ensure folder exists
            let folder = clipsJsonUrl.deletingLastPathComponent()
            try? FileManager.default.createDirectory(
                at: folder,
                withIntermediateDirectories: true
            )

            try? JSONEncoder().encode(newValue).write(to: clipsJsonUrl)
        }
    }

    //    var clips: [Clip] {
    //        get {
    //            (try? JSONDecoder().decode([Clip].self, from: clipsData)) ?? []
    //        }
    //        set {
    //            objectWillChange.send()
    //            clipsData = (try? JSONEncoder().encode(newValue)) ?? Data()
    //        }
    //    }

    //    func generateThumbnail(
    //        for url: URL,
    //        maxSize: CGSize = CGSize(width: 256, height: 256)
    //    ) -> NSImage? {
    //        guard let image = NSImage(contentsOf: url) else { return nil }
    //
    //        let thumbnail = NSImage(size: maxSize)
    //        thumbnail.lockFocus()
    //
    //        let rect = NSRect(origin: .zero, size: maxSize)
    //        image.draw(in: rect, from: .zero, operation: .copy, fraction: 1.0)
    //
    //        thumbnail.unlockFocus()
    //        return thumbnail
    //    }

    init() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .map { _ in NSPasteboard.general.changeCount }
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .compactMap { [weak self] changeCount -> Clip? in
                guard let self else { return nil }

                guard changeCount != self.lastChangeCount else {
                    return nil
                }

                self.lastChangeCount = changeCount

                print("compact Map")

                if let data = NSPasteboard.general.data(forType: .fileURL),
                    let url = URL(dataRepresentation: data, relativeTo: nil)
                {
                    //                    let id = UUID()

                    print("fileurl: \(url)")
                    let bookmark = try? url.bookmarkData(
                        options: [.withSecurityScope],
                        includingResourceValuesForKeys: nil,
                        relativeTo: nil
                    )

                    var type = ClipType.other
                    //                    var thumbnailPath : String?

                    if url.isDirectory {
                        type = .directory
                    } else if [
                        "png", "jpeg", "jpg", "JPG", "gif", "tiff", "webp",
                    ].contains(url.pathExtension) {
                        type = .imagefile
                        //                        if let imageData = NSImage(contentsOf: url) {
                        //                            print(imageData)
                        //                            if let tiffRep = imageData.tiffRepresentation {
                        //                                print("tiffed")
                        //                                data = tiffRep
                        //                            }
                        //                        }

                        //                        if let thumbnail = generateThumbnail(for: url),
                        //                            let tiff = thumbnail.tiffRepresentation,
                        //                            let bitmap = NSBitmapImageRep(data: tiff),
                        //                            let pngData = bitmap.representation(
                        //                                using: .png,
                        //                                properties: [:]
                        //                            )
                        //                        {
                        //                            let thumbURL =
                        //                                cacheFolderURL.appendingPathComponent(
                        //                                    "\(id).png"
                        //                                )
                        //                            try? pngData.write(to: thumbURL)
                        //                            thumbnailPath = thumbURL.path
                        //                        }
                    } else {
                        type = .file
                    }

                    return Clip(
                        //                        id: id,
                        title: FileManager.default.displayName(
                            atPath: url.path()
                        ),
                        content: url.dataRepresentation.base64EncodedString(),
                        type: type,
                        fileBookmark: bookmark,
                        //                        thumbnailPath: thumbnailPath
                    )
                }

                if let data = NSPasteboard.general.data(forType: .string) {
                    print("copy string data")
                    return Clip(
                        title: Date().formatted(),
                        content: String(decoding: data, as: UTF8.self),
                        type: .text
                    )
                }

                if let items = NSPasteboard.general.pasteboardItems,
                    let item = items.first,
                    let imageData = item.data(forType: .png)
                {
                    return Clip(
                        title: Date().formatted(),
                        content: imageData.base64EncodedString(),
                        type: .image
                    )
                }

//                if let image = NSImage(pasteboard: NSPasteboard.general),
//                    let tiff = image.tiffRepresentation
//                {
//                    return Clip(
//                        title: "",
//                        content: tiff.base64EncodedString(),
//                        type: .image
//                    )
//                }

                return nil
            }
            .removeDuplicates()
            .sink { [weak self] newClip in
                guard let self else { return }

                self.activeClip = newClip

                if self.clips.count == self.clipsHistoryLimit {
                    _ = self.clips.popLast()
                }

                if !self.clips.contains(newClip) {
                    self.clips.insert(newClip, at: 0)
                }
            }
    }
}
