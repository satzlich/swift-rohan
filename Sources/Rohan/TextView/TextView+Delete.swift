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

    guard !deletionRange.textRange.isEmpty && deletionRange.immediate else {
      // update selection without deletion
      documentManager.textSelection = RhTextSelection(deletionRange.textRange)
      reconcileSelection()
      return
    }

    do {
      // perform edit
      let location = try documentManager.replaceCharacters(in: deletionRange.textRange, with: "")
      // normalize new location
      let resolved = location ?? deletionRange.textRange.location
      guard let normalized = documentManager.normalizeLocation(resolved) else { return }
      documentManager.textSelection = RhTextSelection(normalized)
      // update layout
      needsLayout = true
    }
    catch {
      assertionFailure("Failed to delete characters: \(error)")
    }
  }
}
