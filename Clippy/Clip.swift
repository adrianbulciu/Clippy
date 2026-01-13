//
//  Clip.swift
//  Clippy
//
//  Created by Adrian Bulciu on 06.01.2026.
//

import SwiftUI

enum ClipType: Codable {
    case file, directory, image, imagefile, text, other

    var value: String {
        switch self {
        case .directory: return "folder"
        case .file: return "file"
        case .image: return "image"
        case .imagefile: return "imagefile"
        case .text: return "text"
        case .other: return "other"
        }
    }
}

struct Clip: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var type: ClipType
    var date: Date = Date()
    var fileBookmark: Data?  // for files
    var originalPath: String?
//    var thumbnailPath: String?  // cached preview

    static func == (lhs: Clip, rhs: Clip) -> Bool {
        return lhs.content == rhs.content
    }

    static func != (lhs: Clip, rhs: Clip) -> Bool {
        return lhs.content != rhs.content
    }

}

extension Clip {
    var nsImage: NSImage? {
        guard type == .image,
            let data = Data(base64Encoded: content)
        else { return nil }

        if let image = NSImage(data: data) {
            image.size = CGSize(width: 64, height: 64)
            return image
        }
        
        return nil
    }

    var nsImageBookmark: NSImage? {
        var isStale = false

        if let bookmark = self.fileBookmark,
            let url =
                (try? URL(
                    resolvingBookmarkData: bookmark,
                    options: [.withSecurityScope],
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                ))
        {

            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }

                if let image = NSImage(contentsOf: url) {
                    image.size = CGSize(width: 64, height: 64)
                    return image
                }
            }
        }

        return nil
    }
    
//    var testImage: NSImage? {
//        var isStale = false
//
//        if let bookmark = self.fileBookmark,
//            let url =
//                (try? URL(
//                    resolvingBookmarkData: bookmark,
//                    options: [.withSecurityScope],
//                    relativeTo: nil,
//                    bookmarkDataIsStale: &isStale
//                ))
//        {
//
//            if url.startAccessingSecurityScopedResource() {
//                defer { url.stopAccessingSecurityScopedResource() }
//
//                if let image = NSImage(contentsOf: url) {
//                    image.size = CGSize(width: 64, height: 64)
//                    return image
//                }
//            }
//        }
//
//        return nil
//    }
//
//    var nsImageThumbnail: NSImage? {
//        guard let thumbPath = self.thumbnailPath else { return nil }
//        let url = URL(fileURLWithPath: thumbPath)
//        return NSImage(contentsOf: url)
//    }
}
