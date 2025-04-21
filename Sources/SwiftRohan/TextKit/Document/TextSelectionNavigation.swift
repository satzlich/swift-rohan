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
    precondition([.character, .word].contains(destination))

    // if extending, move the focus location
    if extending {
      let focus = AffineLocation(selection.focus, selection.affinity)

      guard
        let focus = documentManager.destinationLocation(
          for: focus, direction: direction, destination: destination, extending: true)
      else { return nil }
      return createTextSelection(
        from: selection.anchor, focus.value, affinity: focus.affinity)
    }
    else {
      let location: AffineLocation?
      let range = selection.textRange

      // if the range is empty, move from the location
      if range.isEmpty {
        let source = AffineLocation(range.location, selection.affinity)
        location = documentManager.destinationLocation(
          for: source, direction: direction, destination: destination, extending: false)
      }
      // if the range is not empty, move from the directing end of the range
      else {
        switch direction {
        case .forward:
          location = AffineLocation(range.endLocation, .downstream)

        case .backward:
          location = AffineLocation(range.location, .downstream)

        case .down:
          // move down starting from the end of the range
          let source = AffineLocation(range.endLocation, selection.affinity)
          location = documentManager.destinationLocation(
            for: source, direction: direction, destination: destination, extending: false)

        case .up:
          // move up starting from the start of the range
          let source = AffineLocation(range.location, selection.affinity)
          location = documentManager.destinationLocation(
            for: source, direction: direction, destination: destination, extending: false)

        default:
          assertionFailure("Unsupported direction")
          location = nil
        }
      }
      return location.map { RhTextSelection($0) }
    }
  }

  /// Returns the range to be deleted when the user presses the delete key.
  ///
  /// - Returns: The range to be deleted, or nil if deletion is not allowed.
  /// - Note: If the range is empty, the cursor should be moved to the start of
  ///     the range without deleting anything. If the `isImmediate` flag is true,
  ///     the deletion should be performed immediately; otherwise, the deletion
  ///     can be deferred.
  internal func deletionRange(
    for selection: RhTextSelection,
    direction: Direction,
    destination: Destination,
    allowsDecomposition: Bool
  ) -> DeletionRange? {
    precondition(direction == .forward || direction == .backward)
    precondition(destination == .character || destination == .word)

    let current = selection.textRange
    if !current.isEmpty {
      return DeletionRange(current, isImmediate: true)
    }
    assert(current.isEmpty)

    // compute the candidate range
    let candidate: RhTextRange?
    if direction == .forward {
      let source = AffineLocation(current.location, selection.affinity)
      guard
        let next = documentManager.destinationLocation(
          for: source, direction: .forward, destination: destination, extending: false)
      else { return nil }
      candidate = RhTextRange(current.location, next.value)
    }
    else {
      let source = AffineLocation(current.location, selection.affinity)
      guard
        let previous = documentManager.destinationLocation(
          for: source, direction: .backward, destination: destination, extending: false)
      else { return nil }
      candidate = RhTextRange(previous.value, current.location)
    }
    guard let candidate else { return nil }

    // repair the candidate range
    let repaired = documentManager.repairTextRange(candidate)
    switch repaired {
    case .original(let range):
      return DeletionRange(range, isImmediate: true)
    case .repaired(let range):
      return DeletionRange(range, isImmediate: false)
    case .failure:
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

    let bounds = documentManager.usageBounds

    // clamp point to bounds
    let point = point.with(y: point.y.clamped(bounds.minY, bounds.maxY))

    // not in a drag session
    if !selecting || anchors == nil {
      guard let location = documentManager.resolveTextLocation(with: point)
      else { return nil }
      return RhTextSelection(location)
    }
    // in a drag session
    else {
      guard let anchor = anchors?.anchor,
        let focus = documentManager.resolveTextLocation(with: point)
      else { return nil }
      return createTextSelection(from: anchor, focus.value, affinity: focus.affinity)
    }
  }

  // MARK: - Helpers

  private func createTextSelection(
    from anchor: TextLocation, _ focus: TextLocation,
    affinity: RhTextSelection.Affinity
  ) -> RhTextSelection? {
    guard let textRange = RhTextRange(unordered: anchor, focus),
      let repairedRange = documentManager.repairTextRange(textRange).unwrap()
    else { return nil }
    return RhTextSelection(anchor, focus, repairedRange, affinity: affinity)
  }
}
