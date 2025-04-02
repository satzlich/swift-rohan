// Copyright 2024-2025 Lie Yan

import AppKit
import SwiftUI

struct RhCompletionItem: CompletionItem {
  let id: String
  let label: NSAttributedString
  let symbolName: String
  let insertText: String

  var view: NSView {
    NSHostingView(
      rootView: VStack(alignment: .leading) {
        HStack {
          Image(systemName: symbolName).frame(width: 24)
          AttributedText(attrString: label)
          Spacer()
        }
      })
  }
}
