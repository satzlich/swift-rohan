// Copyright 2024-2025 Lie Yan

import Foundation

extension TextView {
  func replaceContents(in range: RhTextRange, with nodes: [Node]?) {

    guard let undoManager = undoManager,
      undoManager.isUndoRegistrationEnabled
    else {
      assertionFailure("UndoManager should not be nil")
      return
    }
  }

  func replaceCharacters(in range: RhTextRange, with string: String) {

  }
}
