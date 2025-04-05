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
  /// Content to insert when the completion item is selected
  let insertText: String
  /// Command record to invoke when the completion item is selected
  let commandRecord: CommandRecord? = nil

  init(id: String, label: AttributedString, symbolName: String, insertText: String) {
    self.id = id
    self.label = label
    self.symbolName = symbolName
    self.insertText = insertText
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
}
