// Copyright 2024-2025 Lie Yan

import Foundation
import SwiftUI

struct AttributedText: NSViewRepresentable {
  let attrString: NSAttributedString

  func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField(labelWithAttributedString: attrString)
    textField.isSelectable = true
    textField.allowsEditingTextAttributes = false
    textField.lineBreakMode = .byWordWrapping
    textField.maximumNumberOfLines = 0
    return textField
  }

  func updateNSView(_ nsView: NSTextField, context: Context) {
    nsView.attributedStringValue = attrString
  }
}
