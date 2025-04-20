// Copyright 2024-2025 Lie Yan

extension DocumentView {
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

  // MARK: - Word Move

  public override func moveWordLeft(_ sender: Any?) {
    updateTextSelections(
      direction: .backward, destination: .word, extending: false, confined: false)
  }

  public override func moveWordRight(_ sender: Any?) {
    updateTextSelections(
      direction: .forward, destination: .word, extending: false, confined: false)
  }

  public override func moveWordLeftAndModifySelection(_ sender: Any?) {
    updateTextSelections(
      direction: .backward, destination: .word, extending: true, confined: false)
  }

  public override func moveWordRightAndModifySelection(_ sender: Any?) {
    updateTextSelections(
      direction: .forward, destination: .word, extending: true, confined: false)
  }

  // MARK: - Helpers

  private func updateTextSelections(
    direction: TextSelectionNavigation.Direction,
    destination: TextSelectionNavigation.Destination,
    extending: Bool,
    confined: Bool
  ) {
    guard let selection = documentManager.textSelection,
      let destination = documentManager.textSelectionNavigation.destinationSelection(
        for: selection, direction: direction, destination: destination,
        extending: extending, confined: confined)
    else { return }

    documentManager.textSelection = destination
    self.setNeedsUpdate(selection: true, scroll: true)
  }
}
