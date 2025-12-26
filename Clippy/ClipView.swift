//
//  ClipView.swift
//  Clippy
//
//  Created by Adrian Bulciu on 26.12.2025.
//

import SwiftUI

struct ClipView: View {
    var clip: Clip
    @State private var isHovering = false

    var body: some View {
        Text(clip.text)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(5)
            .background(isHovering ? Color.secondary.opacity(0.2) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onHover { hovering in
                withAnimation(.linear(duration: 0.1)) {
                    isHovering = hovering
                }
            }
    }
}

#Preview {
    ClipView(clip: Clip(id: 1, text: "Hello World"))
}
