// Copyright 2024-2025 Lie Yan

extension TextView {
  public override func moveLeft(_ sender: Any?) {
    updateTextSelections(
      direction: .backward, destination: .character, extending: false, confined: false)
    reconcileSelection()
  }

  public override func moveRight(_ sender: Any?) {
    updateTextSelections(
      direction: .forward, destination: .character, extending: false, confined: false)
    reconcileSelection()
  }

  func updateTextSelections(
    direction: TextSelectionNavigation.Direction,
    destination: TextSelectionNavigation.Destination,
    extending: Bool,
    confined: Bool
  ) {
    documentManager.textSelection = documentManager.textSelection.flatMap {
      textSelection in
      documentManager.textSelectionNavigation.destinationSelection(
        for: textSelection, direction: direction,
        destination: destination, extending: extending, confined: confined)
    }
  }
}
