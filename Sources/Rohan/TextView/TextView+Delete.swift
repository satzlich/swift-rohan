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
    guard let current = documentManager.textSelection else { return }
    let deletionRange = documentManager.textSelectionNavigation.deletionRange(
      for: current, direction: direction, destination: .character, allowsDecomposition: false)
    guard let deletionRange else { return }

    guard !deletionRange.textRange.isEmpty && deletionRange.immediate else {
      documentManager.textSelection = RhTextSelection(deletionRange.textRange)
      reconcileSelection()
      return
    }

    do {
      let location = try documentManager.replaceCharacters(in: deletionRange.textRange, with: "")
      documentManager.ensureLayout(delayed: true)
      let target = documentManager.normalizeLocation(location ?? deletionRange.textRange.location)
      guard let target else { return }
      documentManager.textSelection = RhTextSelection(target)
      reconcileSelection()
    }
    catch {
      Rohan.logger.error("Failed to delete characters: \(error)")
    }
  }
}
