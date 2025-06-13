// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView {
  public override func insertLineBreak(_ sender: Any?) {
    guard let selection = documentManager.textSelection?.textRange else { return }

    beginEditing()
    replaceContentsForEdit(in: selection, with: [LinebreakNode()])
    endEditing()
  }

  public override func insertNewline(_ sender: Any?) {
    guard let selection = documentManager.textSelection?.textRange else { return }
    let content = documentManager.resolveInsertParagraphBreak(at: selection)

    beginEditing()
    replaceContentsForEdit(in: selection, with: content)
    endEditing()
  }

  public override func insertTab(_ sender: Any?) {
    insertText("\t", replacementRange: .notFound)
  }
}
