//
//  URL_isDirectory_Extension.swift
//  Clippy
//
//  Created by Adrian Bulciu on 06.01.2026.
//

import SwiftUI

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
