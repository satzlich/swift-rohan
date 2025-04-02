// Copyright 2024-2025 Lie Yan

import Foundation

extension TreeUtils {
  /// Move caret to the next/previous location.
  /// - Returns: The new location of the caret. Nil if the given location is invalid.
  static func moveCaretLR(
    _ location: TextLocation, in direction: TextSelectionNavigation.Direction,
    _ rootNode: RootNode
  ) -> TextLocation? {
    precondition([.forward, .backward].contains(direction))

    guard var trace = Trace.from(location, rootNode) else { return nil }

    switch direction {
    case .forward:
      trace.moveForward()
      return trace.toTextLocation()

    case .backward:
      trace.moveBackward()
      return trace.toTextLocation()

    default:
      assertionFailure("Unexpected direction")
      return nil
    }
  }
}
