// Copyright 2024-2025 Lie Yan

import AppKit

public struct TextSelectionNavigation {
  public typealias Direction = NSTextSelectionNavigation.Direction
  public typealias Destination = NSTextSelectionNavigation.Destination
  public typealias Modifier = NSTextSelectionNavigation.Modifier

  private let documentManager: DocumentManager

  init(_ documentManager: DocumentManager) {
    self.documentManager = documentManager
  }

  public func destinationSelection(
    for selection: RhTextSelection, direction: Direction,
    destination: Destination, extending: Bool, confined: Bool
  ) -> RhTextSelection? {
    precondition([.forward, .backward, .up, .down].contains(direction))

    if !extending {
      // we are not extending
      let location = destinationLocation(for: selection, direction: direction)
      return location.map { RhTextSelection($0) }
    }
    else {
      // we are extending
      let anchor = selection.anchor

      guard
        let focus = documentManager.destinationLocation(
          for: selection.focus, direction, extending: true),
        let textRange = RhTextRange(unordered: anchor, focus),
        let effectiveRange = documentManager.repairTextRange(textRange).unwrap()
      else { return nil }
      return RhTextSelection(anchor, focus, effectiveRange)
    }

    func destinationLocation(
      for selection: RhTextSelection, direction: Direction
    ) -> TextLocation? {
      guard let effectiveRange = selection.getEffectiveRange() else { return nil }

      if effectiveRange.isEmpty {
        return documentManager.destinationLocation(
          for: effectiveRange.location, direction, extending: false)
      }
      else {
        switch direction {
        case .forward, .down:
          return effectiveRange.endLocation
        case .backward, .up:
          return effectiveRange.location
        default:
          assertionFailure("Unsupported direction")
          return nil
        }
      }
    }
  }

  /**
   Returns the range to be deleted when the user presses the delete key.

   - Returns: The range to be deleted, or `nil` if deletion is not allowed.
    If the range is empty, the cursor should be moved to the start of the range
    without deleting anything.
    If the `immediate` flag is `true`, the deletion should be performed immediately;
    otherwise, the deletion can be deferred.
   */
  func deletionRange(
    for textSelection: RhTextSelection,
    direction: Direction,
    destination: Destination,
    allowsDecomposition: Bool
  ) -> DeletionRange? {
    precondition(direction == .forward || direction == .backward)

    guard let current = textSelection.getEffectiveRange() else { return nil }
    // if the text range is non-empty, return it with the immediate flag set to true
    guard current.isEmpty else { return DeletionRange(current, true) }

    // otherwise, compute the target range
    let candidate: RhTextRange
    if direction == .forward {
      guard
        let next = documentManager.destinationLocation(
          for: current.location, .forward, extending: false),
        let candidate_ = RhTextRange(current.location, next)
      else { return nil }
      candidate = candidate_
    }
    else {
      guard
        let previous = documentManager.destinationLocation(
          for: current.location, .backward, extending: false),
        let candidate_ = RhTextRange(previous, current.location)
      else { return nil }
      candidate = candidate_
    }
    let repaired = documentManager.repairTextRange(candidate)
    switch repaired {
    case .original(let range):
      return DeletionRange(range, true)
    case .repaired(let range):
      return DeletionRange(range, false)
    case .unrepairable:
      return nil
    }
  }

  public func textSelection(
    interactingAt point: CGPoint,
    anchors: RhTextSelection?,
    modifiers: Modifier,
    selecting: Bool,
    bounds: CGRect
  ) -> RhTextSelection? {
    guard let location = documentManager.resolveTextLocation(interactingAt: point)
    else { return nil }
    return RhTextSelection(location)
  }
}
