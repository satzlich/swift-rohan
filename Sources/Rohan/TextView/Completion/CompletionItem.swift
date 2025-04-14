// Copyright 2024-2025 Lie Yan

import AppKit
import SatzAlgorithms
import SwiftUI

struct CompletionItem: Identifiable {
  let id: String
  private let iconSymbol: String
  private let label: AttributedString
  let record: CommandRecord
  private let preview: AttributedString

  init(id: String, _ result: CompletionProvider.Result, _ query: String) {
    self.id = id

    let baseAttrs = CompositorStyle.baseAttrs
    let emphAttrs = CompositorStyle.emphAttrs

    self.label = {
      let label = generateLabel(result, query, baseAttrs, emphAttrs: emphAttrs)
      return AttributedString(label)
    }()
    self.iconSymbol = Self.symbolName(for: result.key)
    self.record = result.value
    self.preview = {
      let string = Self.preview(for: result.value)
      let preview = NSAttributedString(string: string, attributes: baseAttrs)
      return AttributedString(preview)
    }()
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

private func generateLabel(
  _ result: CompletionProvider.Result, _ query: String,
  _ baseAttrs: [NSAttributedString.Key: Any],
  emphAttrs: [NSAttributedString.Key: Any]
) -> NSAttributedString {
  let label = result.key

  switch result.matchType {
  case .prefix, .prefixMinus, .nGramMinus, .subSequence:
    return decorateLabel(label, by: query, baseAttrs, emphAttrs: emphAttrs)

  case .nGram:
    let n = CompletionProvider.gramSize
    return decorateLabel_nGram(label, by: query, baseAttrs, emphAttrs: emphAttrs, n)
  }
}

private func decorateLabel(
  _ label: String, by pattern: String,
  _ baseAttrs: [NSAttributedString.Key: Any],
  emphAttrs: [NSAttributedString.Key: Any]
) -> NSAttributedString {

  let attributedString = NSMutableAttributedString(string: label)
  attributedString.setAttributes(baseAttrs, range: NSRange(0..<label.count))

  let label = label.lowercased().utf16
  let pattern = pattern.lowercased().utf16

  guard !pattern.isEmpty else { return attributedString }

  var i = label.startIndex
  var ii = 0
  var j = pattern.startIndex

  var emphRange: Range<Int>?

  while i < label.endIndex && j < pattern.endIndex {
    if label[i] == pattern[j] {
      if let range = emphRange {
        emphRange = range.lowerBound..<ii + 1
      }
      else {
        emphRange = ii..<ii + 1
      }
      j = pattern.index(after: j)
    }
    else if let range = emphRange {
      attributedString.addAttributes(emphAttrs, range: NSRange(range))
      emphRange = nil
    }

    i = label.index(after: i)
    ii += 1
  }

  if let range = emphRange {
    attributedString.addAttributes(emphAttrs, range: NSRange(range))
  }

  return attributedString
}

private func decorateLabel_nGram(
  _ label: String, by pattern: String,
  _ baseAttrs: [NSAttributedString.Key: Any],
  emphAttrs: [NSAttributedString.Key: Any],
  _ gramSize: Int
) -> NSAttributedString {
  precondition(gramSize > 1)

  let attributedString = NSMutableAttributedString(string: label)
  attributedString.setAttributes(baseAttrs, range: NSRange(0..<label.count))

  guard !pattern.isEmpty else { return attributedString }

  let labelGrams = Satz.nGrams(of: label.lowercased(), n: gramSize)
  let patternGrams = Satz.nGrams(of: pattern.lowercased(), n: gramSize)

  var i = 0
  var ii = 0
  var j = 0
  var emphRange: Range<Int>?

  while i < labelGrams.count && j < patternGrams.count {
    if labelGrams[i] == patternGrams[j] {
      if let range = emphRange {
        emphRange = range.lowerBound..<ii + labelGrams[i].utf16.count
      }
      else {
        emphRange = ii..<ii + labelGrams[i].utf16.count
      }
      j += 1
    }
    else if let range = emphRange {
      attributedString.addAttributes(emphAttrs, range: NSRange(range))
      emphRange = nil
    }

    ii += labelGrams[i].first!.utf16.count
    i += 1
  }

  if let range = emphRange {
    attributedString.addAttributes(emphAttrs, range: NSRange(range))
  }

  return attributedString
}
