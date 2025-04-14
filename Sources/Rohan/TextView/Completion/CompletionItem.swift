// Copyright 2024-2025 Lie Yan

import AppKit
import SwiftUI

struct CompletionItem: Identifiable {
  let id: String
  private let iconSymbol: String
  private let label: AttributedString
  let record: CommandRecord
  private let preview: AttributedString

  init(id: String, _ record: CommandRecord, _ query: String) {
    self.id = id

    let attributes: [NSAttributedString.Key: Any] = [.font: CompositorStyle.font]
    let emphAtts: [NSAttributedString.Key: Any] = [
      .font: CompositorStyle.font,
      .foregroundColor: NSColor.systemBlue,
    ]

    let label = decorateLabel(
      record.name, by: query, attributes, emphAttrs: emphAtts)
    self.label = AttributedString(label)

    self.iconSymbol = Self.symbolName(for: record.name)
    self.record = record

    let preview =
      NSAttributedString(string: Self.preview(for: record), attributes: attributes)
    self.preview = AttributedString(preview)
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

private func decorateLabel(
  _ label: String, by pattern: String, _ baseAttrs: [NSAttributedString.Key: Any],
  emphAttrs: [NSAttributedString.Key: Any]
) -> NSAttributedString {
  let attributedString = NSMutableAttributedString(string: label)
  let labelChars = Array(label)
  let patternChars = Array(pattern)

  guard !pattern.isEmpty else { return attributedString }

  let labelRange = NSRange(location: 0, length: label.count)
  attributedString.setAttributes(baseAttrs, range: labelRange)

  var j = 0
  var emphRange: NSRange?

  for (i, char) in labelChars.enumerated() where j < patternChars.count {
    if char == patternChars[j] {
      if let range = emphRange {
        emphRange = NSRange(location: range.location, length: i - range.location + 1)
      }
      else {
        emphRange = NSRange(location: i, length: 1)
      }
      j += 1
    }
    else if let range = emphRange {
      attributedString.addAttributes(emphAttrs, range: range)
      emphRange = nil
    }
  }

  if let range = emphRange {
    attributedString.addAttributes(emphAttrs, range: range)
  }

  return attributedString
}
