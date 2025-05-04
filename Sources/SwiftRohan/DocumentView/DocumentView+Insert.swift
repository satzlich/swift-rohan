// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView {
  public override func insertLineBreak(_ sender: Any?) {
    guard let selection = documentManager.textSelection?.textRange
    else { return }
    let result = replaceContentsForEdit(in: selection, with: [LinebreakNode()])
    switch result {
    case .success:
      self.documentContentDidChange()

    case .userError(_):
      self.notifyOperationRejected()

    case .internalError(let error):
      assertionFailure("Internal error: \(error)")
      self.documentContentDidChange()
    }
  }

  public override func insertNewline(_ sender: Any?) {
    guard let selection = documentManager.textSelection?.textRange
    else { return }
    let content = documentManager.resolveInsertParagraphBreak(at: selection)
    replaceContentsForEdit(
      in: selection, with: content, message: "Failed to insert newline.")
    self.documentContentDidChange()
  }

  public override func insertTab(_ sender: Any?) {
    insertText(Strings.tab, replacementRange: .notFound)
  }
}
