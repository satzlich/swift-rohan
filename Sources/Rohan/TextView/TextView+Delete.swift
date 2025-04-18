// Copyright

import Foundation

extension TextView {
  public override func deleteForward(_ sender: Any?) {
    performDelete(.forward)
  }

  public override func deleteBackward(_ sender: Any?) {
    performDelete(.backward)
  }

  private func performDelete(_ direction: TextSelectionNavigation.Direction) {
    guard let selection = documentManager.textSelection,
      let deletionRange = documentManager.textSelectionNavigation.deletionRange(
        for: selection, direction: direction, destination: .character,
        allowsDecomposition: false)
    else { return }

    let textRange = deletionRange.textRange

    if !textRange.isEmpty && deletionRange.isImmediate {
      undoManager?.beginUndoGrouping()

      replaceContentsForEdit(in: textRange, with: nil, message: "Failed to delete")

      if documentManager.isEmpty {
        replaceContentsForEdit(in: documentManager.documentRange, with: [ParagraphNode()])
        moveBackward(self)
      }

      undoManager?.endUndoGrouping()
    }
    else {
      // update selection without deletion
      documentManager.textSelection = RhTextSelection(textRange)
      // request update
      self.setNeedsUpdate(selection: true)
    }
  }
}
