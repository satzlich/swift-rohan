// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

@testable import Rohan

/// DocumentManager Utilities
enum DMUtils {
  /// Copy nodes in the given range.
  static func copyNodes(
    in range: RhTextRange, _ documentManager: DocumentManager
  ) throws -> [Node] {
    var nodes: [Node] = []
    try documentManager.enumerateContents(in: range) { (_, node) in
      nodes.append(node.deepCopy())
      return true  // continue
    }
    return nodes
  }

  /// Replace contents in the given range with the given nodes.
  /// - Returns: the range of inserted content and the deleted nodes
  static func replaceContents(
    in range: RhTextRange, with nodes: [Node]?, _ documentManager: DocumentManager
  ) -> (RhTextRange, [Node]) {
    do {
      let deleted = try copyNodes(in: range, documentManager)
      let result = documentManager.replaceContents(in: range, with: nodes)
      return result.map { range in (range, deleted) }.success()!
    }
    catch {
      fatalError("Failed to replace contents in range: \(range)")
    }
  }

  /// Replace contents in the given range with the given string.
  /// - Returns: the range of inserted content and the deleted nodes
  static func replaceCharacters(
    in range: RhTextRange, with string: BigString, _ documentManager: DocumentManager
  ) -> (RhTextRange, [Node]) {
    do {
      let deleted = try copyNodes(in: range, documentManager)
      let result = documentManager.replaceCharacters(in: range, with: string)
      return result.map { range in (range, deleted) }.success()!
    }
    catch {
      fatalError("Failed to replace characters in range: \(range)")
    }
  }
}
