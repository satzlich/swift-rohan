// Copyright 2024-2025 Lie Yan

import AppKit
import SwiftUI

struct RhCompletionItem: CompletionItem {
  let id: String
  let label: AttributedString
  let symbolName: String
  let insertText: String

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
