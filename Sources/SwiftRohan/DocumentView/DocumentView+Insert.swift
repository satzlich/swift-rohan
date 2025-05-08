// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView {
  public override func insertLineBreak(_ sender: Any?) {
    guard let selection = documentManager.textSelection?.textRange
    else { return }

    beginEditing()
    defer { endEditing() }

    replaceContentsForEdit(in: selection, with: [LinebreakNode()])
  }

  public override func insertNewline(_ sender: Any?) {
    guard let selection = documentManager.textSelection?.textRange
    else { return }
    let content = documentManager.resolveInsertParagraphBreak(at: selection)

    beginEditing()
    defer { endEditing() }
    replaceContentsForEdit(
      in: selection, with: content, message: "Failed to insert newline.")
  }

  public override func insertTab(_ sender: Any?) {
    insertText(Strings.tab, replacementRange: .notFound)
  }

  // MARK: - Math

  func removeSuperscript(_ sender: Any?) {

  }

  func removeSubscript(_ sender: Any?) {

  }
}
