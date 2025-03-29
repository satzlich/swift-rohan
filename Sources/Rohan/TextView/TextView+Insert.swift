// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  public override func insertLineBreak(_ sender: Any?) {
    // insert line separator
    insertText("\u{2028}", replacementRange: .notFound)
  }

  public override func insertNewline(_ sender: Any?) {
    guard let selection = documentManager.textSelection?.effectiveRange else { return }
    let content = documentManager.resolveInsertParagraphBreak(at: selection)

    documentManager.beginEditing()
    let result = self.replaceContents(in: selection, with: content, registerUndo: true)
    documentManager.endEditing()

    switch result {
    case .success(let range):
      documentManager.textSelection = RhTextSelection(range.endLocation)
    case .failure(let error):
      if error.code == .InvalidInsertOperation {
        Rohan.logger.error("Content to insert is incompatible.")
      }
      else {
        Rohan.logger.error("Failed to insert paragraph break: \(error)")
      }
    }
  }

  public override func insertTab(_ sender: Any?) {
    insertText("\u{0009}", replacementRange: .notFound)
  }
}
