// Copyright

import Foundation

extension DocumentView {
  public override func deleteForward(_ sender: Any?) {
    _performDelete(.forward, destination: .character)
  }

  public override func deleteBackward(_ sender: Any?) {
    _performDelete(.backward, destination: .character)
  }

  public override func deleteWordBackward(_ sender: Any?) {
    _performDelete(.backward, destination: .word)
  }

  private func _performDelete(
    _ direction: TextSelectionNavigation.Direction,
    destination: TextSelectionNavigation.Destination
  ) {
    precondition(direction == .forward || direction == .backward)
    precondition(destination == .character || destination == .word)

    guard let selection = documentManager.textSelection,
      let deletionRange =
        documentManager.textSelectionNavigation
        .deletionRange(for: selection, direction: direction, destination: destination)
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
      let selection: RhTextSelection =
        // for both directions, set the affinity so that the extent of deleted range
        // is conspicuous, especially for boundary cases where the deletion range
        // edges are at the beginning or end of a line.
        switch direction {
        case .forward:
          RhTextSelection(textRange, affinity: .downstream)
        case .backward:
          RhTextSelection(textRange, affinity: .upstream)
        default:
          preconditionFailure("Unsupported direction: \(direction)")
        }

      documentManager.textSelection = selection
      self.documentSelectionDidChange()
    }
  }
}
