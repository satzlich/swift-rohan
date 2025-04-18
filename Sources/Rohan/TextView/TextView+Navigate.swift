// Copyright 2024-2025 Lie Yan

extension TextView {
  // MARK: - Horizontal Move

  public override func moveForward(_ sender: Any?) {
    updateTextSelections(
      direction: .forward, destination: .character, extending: false, confined: false)
  }

  public override func moveBackward(_ sender: Any?) {
    updateTextSelections(
      direction: .backward, destination: .character, extending: false, confined: false)
  }

  public override func moveLeft(_ sender: Any?) {
    moveBackward(sender)
  }

  public override func moveLeftAndModifySelection(_ sender: Any?) {
    updateTextSelections(
      direction: .backward, destination: .character, extending: true, confined: false)
  }

  public override func moveRight(_ sender: Any?) {
    moveForward(sender)
  }

  public override func moveRightAndModifySelection(_ sender: Any?) {
    updateTextSelections(
      direction: .forward, destination: .character, extending: true, confined: false)
  }

  // MARK: - Vertical Move

  public override func moveUp(_ sender: Any?) {
    updateTextSelections(
      direction: .up, destination: .character, extending: false, confined: false)
  }

  public override func moveUpAndModifySelection(_ sender: Any?) {
    updateTextSelections(
      direction: .up, destination: .character, extending: true, confined: false)
  }

  public override func moveDown(_ sender: Any?) {
    updateTextSelections(
      direction: .down, destination: .character, extending: false, confined: false)
  }

  public override func moveDownAndModifySelection(_ sender: Any?) {
    updateTextSelections(
      direction: .down, destination: .character, extending: true, confined: false)
  }

  public override func selectAll(_ sender: Any?) {
    documentManager.textSelection = RhTextSelection(documentManager.documentRange)
    self.setNeedsUpdate(selection: true)
  }

  // MARK: - Helpers

  private func updateTextSelections(
    direction: TextSelectionNavigation.Direction,
    destination: TextSelectionNavigation.Destination,
    extending: Bool,
    confined: Bool
  ) {
    guard let currentSelection = documentManager.textSelection else { return }
    let destinationSelection =
      documentManager.textSelectionNavigation.destinationSelection(
        for: currentSelection, direction: direction, destination: destination,
        extending: extending, confined: confined)
    guard let destinationSelection else { return }
    documentManager.textSelection = destinationSelection
    self.setNeedsUpdate(selection: true, scroll: true)
  }
}
