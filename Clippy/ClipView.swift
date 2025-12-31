//
//  ClipView.swift
//  Clippy
//
//  Created by Adrian Bulciu on 26.12.2025.
//

import SwiftUI

struct ClipView: View {
    var text: String
    @State private var isHovering = false

    var body: some View {
        Text(text)
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(isHovering ? Color.secondary.opacity(0.2) : .clear)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary.opacity(0.1), lineWidth: 1))
            .onHover { hovering in
                withAnimation(.linear(duration: 0.1)) {
                    isHovering = hovering
                }
            }
    }
}

#Preview {
    ClipView(text: "Hello World")
}
