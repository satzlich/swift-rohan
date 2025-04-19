// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

@testable import SwiftRohan

/// DocumentManager Utilities
enum DMUtils {
  /// Copy nodes in the given range.
  static func copyNodes(
    in range: RhTextRange, _ documentManager: DocumentManager
  ) throws -> [Node] {
    documentManager.mapContents(in: range, { $0.deepCopy() }) ?? []
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
