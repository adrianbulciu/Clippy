//
//  ClipView.swift
//  Clippy
//
//  Created by Adrian Bulciu on 26.12.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ClipView: View {
    let clip: Clip
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(clip.type.value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding([.top, .bottom], 5)

                Spacer()

                Text(clip.date.formatted())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding([.top, .bottom], 5)
            }

            switch clip.type {
            case .text:
                Text(clip.content)
                    .lineLimit(3)
                    .alignmentGuide(.leading) { d in d[.leading] }
            case .imagefile:
                if let image = clip.nsImageBookmark {
                    HStack {
                        Image(nsImage: image)
                            //                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 100)
                        Text(clip.title)
                            .lineLimit(3)
                            .font(.title2)
                    }

                } else {
                    EmptyView()
                }
            case .image:
                if let image = clip.nsImage {
                    HStack {
                        Image(nsImage: image)
                            //                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 100)
                        Text(clip.title)
                            .lineLimit(3)
                            .font(.title2)
                    }

                } else {
                    EmptyView()
                }
            case .directory:
                Label {
                    Text(clip.title)
                } icon: {
                    Image(systemName: "folder.fill")
                        .frame(width: 20)
                }
                .font(.title2)
            case .file:
                if let image = clip.nsImageBookmark {
                    HStack {
                        Image(nsImage: image)
                            //                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 100)
                        Text(clip.title)
                            .lineLimit(3)
                            .font(.title2)
                    }
                } else {
                    Label {
                        Text(clip.title)
                    } icon: {
                        Image(systemName: "document.fill")
                            .frame(width: 20)
                    }
                    .font(.title2)
                }

            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.bottom], 30)
        .padding([.top, .leading, .trailing], 15)
        .background(isHovering ? Color.secondary.opacity(0.2) : .clear)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(
                Color.secondary.opacity(0.1),
                lineWidth: 1
            )
        )
        .onHover { hovering in
            withAnimation(.linear(duration: 0.1)) {
                isHovering = hovering
            }
        }
        .onAppear {
            //            print(clip.content)
            //                        print(clip.nsImageBookmark)

        }
    }
}

#Preview {
    ClipView(
        clip: ClipboardViewModel().clips[2]
        //             clip: Clip(title: "Hello World", content: "Some Content", type: .text)
    )
}
