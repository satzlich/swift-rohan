// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  public override func insertLineBreak(_ sender: Any?) {
    insertText(Strings.lineSeparator, replacementRange: .notFound)
  }

  public override func insertNewline(_ sender: Any?) {
    guard let selection = documentManager.textSelection?.textRange
    else { return }
    let content = documentManager.resolveInsertParagraphBreak(at: selection)
    _ = replaceContentsForEdit(
      in: selection, with: content, message: "Failed to insert newline.")
  }

  public override func insertTab(_ sender: Any?) {
    insertText(Strings.tab, replacementRange: .notFound)
  }
}
