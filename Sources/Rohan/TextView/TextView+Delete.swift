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

    let textRange = deletionRange.textRange

    guard !textRange.isEmpty && deletionRange.isImmediate else {
      // update selection without deletion
      documentManager.textSelection = RhTextSelection(textRange)
      // request update
      self.setNeedsUpdate(selection: true)
      return
    }

    // perform edit
    _ = replaceContentsForEdit(
      in: textRange, with: nil, message: "Failed to perform deletion")
  }
}
