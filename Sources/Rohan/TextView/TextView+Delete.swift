// Copyright

import Foundation

extension TextView {
  public override func deleteForward(_ sender: Any?) {
    deleteCharacter(.forward)
  }

  public override func deleteBackward(_ sender: Any?) {
    deleteCharacter(.backward)
  }

  func deleteCharacter(_ direction: TextSelectionNavigation.Direction) {
    guard let currentSelection = documentManager.textSelection,
      // compute deletion range from current selection
      let deletionRange = documentManager.textSelectionNavigation.deletionRange(
        for: currentSelection, direction: direction, destination: .character,
        allowsDecomposition: false)
    else { return }

    guard !deletionRange.textRange.isEmpty && deletionRange.isImmediate else {
      // update selection without deletion
      documentManager.textSelection = RhTextSelection(deletionRange.textRange)
      reconcileSelection()
      return
    }

    // perform edit
    documentManager.beginEditing()
    let range = deletionRange.textRange
    let insertionPoint = documentManager.replaceCharacters(in: range, with: "")
    documentManager.endEditing()
    // check result
    guard let resolved = insertionPoint.success()?.location else {
      Rohan.logger.error("Failed to delete characters: \(insertionPoint.failure()!)")
      return
    }
    // set selection
    documentManager.textSelection = RhTextSelection(resolved)
    // update layout
    self.needsLayout = true
  }
}
