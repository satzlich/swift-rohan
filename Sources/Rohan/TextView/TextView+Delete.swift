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
    let result = documentManager.replaceContents(in: range, with: nil)
    documentManager.endEditing()
    // check result
    guard let location = result.success()?.location else {
      Rohan.logger.error("Failed to perform deletion: \(result.failure()!)")
      return
    }
    // set selection
    documentManager.textSelection = RhTextSelection(location)
    // update layout
    self.needsLayout = true
  }
}
