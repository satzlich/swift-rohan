// Copyright 2024-2025 Lie Yan

import AppKit
import SwiftUI

struct RhCompletionItem: CompletionItem {
  let id: String
  let label: NSAttributedString
  let symbolName: String
  let insertText: String

  /// X offset of the completion item in the completion list
  static let displayXDelta: CGFloat = -(16 + iconWidth + padding)
  private static let iconWidth: CGFloat = 12
  private static let padding: CGFloat = iconWidth / 2

  var view: NSView {
    NSHostingView(
      rootView: VStack(alignment: .leading) {
        HStack {
          Spacer(minLength: Self.padding)
          Image(systemName: symbolName)
            .frame(width: Self.iconWidth)
          AttributedText(attrString: label)
          Spacer()
          Spacer(minLength: Self.padding)
        }
      })
  }
}
