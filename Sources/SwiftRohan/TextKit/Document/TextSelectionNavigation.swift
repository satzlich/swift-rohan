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

    switch destination {
    case .character:
      return destinationSelectionForChar(
        for: selection, direction: direction, extending: extending, confined: confined)

    //    case .word:

    default:
      return destinationSelectionForChar(
        for: selection, direction: direction, extending: extending, confined: confined)
    }
  }

  /// Returns the destination selection for a character-based navigation.
  private func destinationSelectionForChar(
    for selection: RhTextSelection, direction: Direction,
    extending: Bool, confined: Bool
  ) -> RhTextSelection? {
    precondition([.forward, .backward, .up, .down].contains(direction))

    // if extending, move the focus location
    if extending {
      guard
        let focus = documentManager.destinationLocation(
          for: selection.focus, direction, extending: true)
      else { return nil }
      return createTextSelection(from: selection.anchor, focus)
    }
    else {
      let location: TextLocation?
      let range = selection.textRange

      // if the range is empty, move from the location
      if range.isEmpty {
        location = documentManager.destinationLocation(
          for: range.location, direction, extending: false)
      }
      // if the range is not empty, move from the directing end of the range
      else {
        switch direction {
        case .forward:
          location = range.endLocation

        case .backward:
          location = range.location

        case .down:
          // move down starting from the end of the range
          location = documentManager.destinationLocation(
            for: range.endLocation, direction, extending: false)

        case .up:
          // move up starting from the start of the range
          location = documentManager.destinationLocation(
            for: range.location, direction, extending: false)

        default:
          assertionFailure("Unsupported direction")
          location = nil
        }
      }
      return location.map(RhTextSelection.init)
    }
  }

  /// Returns the range to be deleted when the user presses the delete key.
  ///
  /// - Returns: The range to be deleted, or nil if deletion is not allowed.
  /// - Note: If the range is empty, the cursor should be moved to the start of
  ///     the range without deleting anything. If the `isImmediate` flag is true,
  ///     the deletion should be performed immediately; otherwise, the deletion
  ///     can be deferred.
  func deletionRange(
    for selection: RhTextSelection,
    direction: Direction,
    destination: Destination,
    allowsDecomposition: Bool
  ) -> DeletionRange? {
    precondition(direction == .forward || direction == .backward)

    // obtain the current text range
    let current = selection.textRange
    // ensure the text range is empty, otherwise return it with "isImmediate=true"
    guard current.isEmpty else { return DeletionRange(current, true) }

    // compute the candidate range
    let candidate: RhTextRange?
    if direction == .forward {
      let next = documentManager.destinationLocation(
        for: current.location, .forward, extending: false)
      guard let next else { return nil }
      candidate = RhTextRange(current.location, next)
    }
    else {
      let previous = documentManager.destinationLocation(
        for: current.location, .backward, extending: false)
      guard let previous else { return nil }
      candidate = RhTextRange(previous, current.location)
    }
    guard let candidate else { return nil }

    // repair the candidate range
    let repaired = documentManager.repairTextRange(candidate)
    switch repaired {
    case .original(let range):
      return DeletionRange(range, true)
    case .repaired(let range):
      return DeletionRange(range, false)
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
    // clamp the point to the bounds
    let usageBounds = documentManager.usageBounds
    let y = point.y.clamped(usageBounds.minY, usageBounds.maxY)
    let point = point.with(y: y)

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
      return createTextSelection(from: anchor, focus)
    }
  }

  // MARK: - Helpers

  private func createTextSelection(
    from anchor: TextLocation, _ focus: TextLocation
  ) -> RhTextSelection? {
    guard let textRange = RhTextRange(unordered: anchor, focus),
      let repairedRange = documentManager.repairTextRange(textRange).unwrap()
    else { return nil }
    return RhTextSelection(anchor, focus, repairedRange)
  }
}
