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
    documentManager.beginEditing()
    let result = documentManager.insertParagraphBreak_v2(at: selection)
    switch result {
    case .success(let range):
      documentManager.endEditing()
      documentManager.textSelection = RhTextSelection(range.endLocation)
    case .failure(let error):
      if error.code == .ContentToInsertIsIncompatible {
        documentManager.endEditing()
      }
      else {
        Rohan.logger.error("Failed to insert paragraph break: \(error)")
        documentManager.endEditing()
      }
    }
  }

  public override func insertTab(_ sender: Any?) {
    insertText("\u{0009}", replacementRange: .notFound)
  }
}
