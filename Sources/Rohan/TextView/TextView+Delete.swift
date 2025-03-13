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

    do {
      // perform edit
      var location: TextLocation? = nil
      try documentManager.performEditingTransaction {
        location = try documentManager.replaceCharacters(
          in: deletionRange.textRange, with: "")
      }
      // set selection
      let resolved = location ?? deletionRange.textRange.location
      documentManager.textSelection = RhTextSelection(resolved)
      // update layout
      self.needsLayout = true
    }
    catch {
      Rohan.logger.error("Failed to delete characters: \(error)")
    }
  }
}
