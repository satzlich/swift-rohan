// Copyright 2024-2025 Lie Yan

import Foundation

/// An object that is crossed over from certain location in certain direction.
enum CrossedObject {
  /// String is expected to have length "1". And the location on the other side.
  case text(String, TextLocation)
  /// Node is expected to be not "TextNode". And the location on the other side.
  case nontextNode(Node, TextLocation)
  /// Cross a block node boundary.
  case blockBoundary
}
