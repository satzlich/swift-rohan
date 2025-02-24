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
    for: RhTextSelection,
    direction: Direction,
    destination: Destination,
    extending: Bool,
    confined: Bool
  ) -> RhTextSelection? {
    preconditionFailure()
  }

  public func deletionRange(
    for textSelection: RhTextSelection,
    direction: Direction,
    destination: Destination,
    allowsDecomposition: Bool
  ) -> RhTextRange {
    preconditionFailure()
  }

  public func textSelection(
    interactingAt point: CGPoint,
    anchors: [RhTextSelection],
    modifiers: Modifier,
    selecting: Bool,
    bounds: CGRect
  ) -> RhTextSelection? {
    guard let location = documentManager.resolveTextLocation(interactingAt: point)
    else { return nil }
    return RhTextSelection(location)
  }
}
