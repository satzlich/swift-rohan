// Copyright 2024-2025 Lie Yan

import AppKit
import SwiftUI

struct RhCompletionItem: CompletionItem {
  /// Identifier for the completion item. UUID suffices.
  let id: String
  /// Label for the completion item
  let label: AttributedString
  /// Icon symbol for the completion item
  let symbolName: String
  /// Command record to invoke when the completion item is selected
  let commandRecord: CommandRecord
  /// Preview of the completion item
  let preview: AttributedString

  init(id: String, _ record: CommandRecord) {
    self.id = id

    let attributes = AttributeContainer([.font: CompositorStyle.font])
    self.label = AttributedString(record.name, attributes: attributes)
    self.symbolName = Self.symbolName(for: record.name)
    self.commandRecord = record
    self.preview = AttributedString(Self.preview(for: record), attributes: attributes)
  }

  /// X offset of the completion item in the completion list
  static let displayXDelta: CGFloat = Constants.displayXDelta
  static let iconPadding: CGFloat = Constants.leadingPadding

  private enum Constants {
    static let leadingPadding: CGFloat = CompositorStyle.leadingPadding
    static let trailingPadding: CGFloat = CompositorStyle.trailingPadding

    static let fontSize: CGFloat = CompositorStyle.fontSize
    static let textXOffset: CGFloat = fontSize + leadingPadding
    static let displayXDelta: CGFloat = -(14 + fontSize + leadingPadding)
  }

  var view: NSView {
    NSHostingView(
      rootView: VStack(alignment: .leading) {
        HStack {
          Image(systemName: symbolName)
            .foregroundColor(.green)
            .font(.system(size: Constants.fontSize))
            .padding(.leading, Constants.leadingPadding)
          Text(label)
          Spacer()
          Text(preview)
            .padding(.trailing, Constants.trailingPadding)
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
      return "note.text"
    }
  }

  private static func preview(for commandRecord: CommandRecord) -> String {
    switch commandRecord.content {
    case .plaintext(let string):
      if string.count == 1 {
        return string
      }
      else {
        return string.prefix(1) + "…"
      }

    default:
      return Strings.dottedSquare
    }
  }
}
