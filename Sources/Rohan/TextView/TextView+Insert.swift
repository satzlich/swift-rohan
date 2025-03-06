// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  public override func insertLineBreak(_ sender: Any?) {
    // insert line separator
    insertText("\u{2028}", replacementRange: NSRange(location: NSNotFound, length: 0))
  }

  public override func insertNewline(_ sender: Any?) {
    print("TODO: insertNewline")
  }

  public override func insertTab(_ sender: Any?) {
    insertText("\u{0009}", replacementRange: NSRange(location: NSNotFound, length: 0))
  }
}
