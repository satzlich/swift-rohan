// Copyright 2024-2025 Lie Yan

import AppKit
import SwiftUI

struct CompletionItem: Identifiable {
  let id: String
  private let iconSymbol: String
  private let label: AttributedString
  let record: CommandRecord
  private let preview: AttributedString

  init(id: String, _ record: CommandRecord) {
    self.id = id

    let attributes = AttributeContainer([.font: CompositorStyle.font])

    self.label = AttributedString(record.name, attributes: attributes)
    self.iconSymbol = Self.symbolName(for: record.name)
    self.record = record
    self.preview = AttributedString(Self.preview(for: record), attributes: attributes)
  }

  private enum Consts {
    static let leadingPadding: CGFloat = CompositorStyle.leadingPadding
    static let trailingPadding: CGFloat = CompositorStyle.trailingPadding
    static let iconSize: CGFloat = CompositorStyle.iconSize
    static let previewSize: CGFloat = CompositorStyle.iconSize
  }

  var view: NSView {
    NSHostingView(
      rootView: VStack(alignment: .leading) {
        HStack {
          Image(systemName: iconSymbol)
            .foregroundColor(.cyan)
            .font(.system(size: Consts.iconSize))
            .padding(.leading, Consts.leadingPadding)
          Text(label)
            .fixedSize(horizontal: true, vertical: false)
            .lineLimit(1)
          Spacer()
          Text(preview)
            .font(.system(size: Consts.previewSize))
            .padding(.trailing, Consts.trailingPadding)
            .lineLimit(1)
        }
      })
  }

  private static func symbolName(for word: String) -> String {
    if let firstChar = word.first,
      firstChar.isASCII, firstChar.isLetter
    {
      return "\(firstChar.lowercased()).square.fill"
    }
    else {
      return "text.insert"
    }
  }

  private static func preview(for commandRecord: CommandRecord) -> String {
    switch commandRecord.content {
    case .plaintext(let string):
      string.count == 1 ? string : string.prefix(2) + "…"
    default:
      Strings.dottedSquare
    }
  }
}
