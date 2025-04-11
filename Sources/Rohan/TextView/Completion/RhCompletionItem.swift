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

  init(id: String, _ record: CommandRecord) {
    self.id = id
    self.label = AttributedString(record.name)
    self.symbolName = Self.symbolName(for: record.name)
    self.commandRecord = record
  }

  /// X offset of the completion item in the completion list
  static let displayXDelta: CGFloat = -(14 + iconWidth + padding)
  private static let iconWidth: CGFloat = 12
  private static let padding: CGFloat = iconWidth / 2

  var view: NSView {
    NSHostingView(
      rootView: VStack(alignment: .leading) {
        HStack {
          Image(systemName: symbolName)
            .frame(width: Self.iconWidth)
            .padding(.leading, Self.padding)
          Text(label)
          Spacer()
        }
      })
  }

  private static func symbolName(for word: String) -> String {
    if let firstChar = word.first, firstChar.isASCII, firstChar.isLetter {
      return "\(firstChar.lowercased()).square"
    }
    else {
      return "note.text"
    }
  }
}
