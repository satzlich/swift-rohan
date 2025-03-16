// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  public override func insertLineBreak(_ sender: Any?) {
    // insert line separator
    insertText("\u{2028}", replacementRange: .notFound)
  }

  public override func insertNewline(_ sender: Any?) {
    guard let range = documentManager.textSelection?.effectiveRange else { return }
    documentManager.beginEditing()
    let result = documentManager.insertParagraphBreak(at: range)
    guard let (insertionPoint, _) = result.success() else {
      Rohan.logger.error("Failed to insert paragraph break: \(result.failure()!)")
      documentManager.endEditing()
      return
    }
    documentManager.endEditing()
    documentManager.textSelection = RhTextSelection(insertionPoint.location)
  }

  public override func insertTab(_ sender: Any?) {
    insertText("\u{0009}", replacementRange: .notFound)
  }
}
