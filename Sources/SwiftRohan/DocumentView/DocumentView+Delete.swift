// Copyright

import Foundation

extension DocumentView {
  public override func deleteForward(_ sender: Any?) {
    performDelete(.forward, destination: .character)
  }

  public override func deleteBackward(_ sender: Any?) {
    performDelete(.backward, destination: .character)
  }

  public override func deleteWordBackward(_ sender: Any?) {
    performDelete(.backward, destination: .word)
  }

  private func performDelete(
    _ direction: TextSelectionNavigation.Direction,
    destination: TextSelectionNavigation.Destination
  ) {
    precondition(destination == .character || destination == .word)

    guard let selection = documentManager.textSelection,
      let deletionRange = documentManager.textSelectionNavigation.deletionRange(
        for: selection, direction: direction, destination: destination)
    else { return }

    let textRange = deletionRange.textRange

    if !textRange.isEmpty && deletionRange.isImmediate {
      beginEditing()
      defer { endEditing() }

      undoManager?.beginUndoGrouping()
      defer { undoManager?.endUndoGrouping() }

      replaceContentsForEdit(in: textRange, with: nil as Array<Node>?)
      if documentManager.isEmpty {
        replaceContentsForEdit(in: documentManager.documentRange, with: [ParagraphNode()])
        moveBackward(self)
      }
    }
    else {
      documentManager.textSelection = RhTextSelection(textRange)
      self.documentSelectionDidChange()
    }
  }
}
