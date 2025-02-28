// Copyright 2024-2025 Lie Yan

extension TextView {
  public override func moveForward(_ sender: Any?) {
    updateTextSelections(
      direction: .forward, destination: .character, extending: false, confined: false)
    reconcileSelection()
  }

  public override func moveBackward(_ sender: Any?) {
    updateTextSelections(
      direction: .backward, destination: .character, extending: false, confined: false)
    reconcileSelection()
  }

  public override func moveLeft(_ sender: Any?) {
    moveBackward(sender)
  }

  public override func moveRight(_ sender: Any?) {
    moveForward(sender)
  }

  func updateTextSelections(
    direction: TextSelectionNavigation.Direction,
    destination: TextSelectionNavigation.Destination,
    extending: Bool,
    confined: Bool
  ) {
    documentManager.textSelection = documentManager.textSelection
      .flatMap { textSelection in
        documentManager.textSelectionNavigation.destinationSelection(
          for: textSelection, direction: direction,
          destination: destination, extending: extending, confined: confined)
      }
  }
}
