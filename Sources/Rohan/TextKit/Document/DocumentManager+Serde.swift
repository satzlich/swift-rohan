// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension DocumentManager {
  /**
   Serialize the contents in the given range to JSON data.
   - Returns: The JSON data, or nil if the range is invalid.
   */
  func jsonData(for range: RhTextRange) -> Data? {
    // obtain nodes in the range
    guard let nodes = getPartialNodes(in: range) else { return nil }
    // serialize
    let encoder = JSONEncoder()
    #if DEBUG
    encoder.outputFormatting = .sortedKeys
    #endif
    return try? encoder.encode(nodes)
  }

  /**
   Serialize the contents in the given range to a lossy string.
   - Returns: The lossy string, or nil if the range is invalid.
   */
  func lossyString(for range: RhTextRange) -> BigString? {
    // obtain nodes in the range
    guard let nodes = getPartialNodes(in: range) else { return nil }
    // serialize
    return StringifyUtils.stringify(nodes)
  }

  private func getPartialNodes(in range: RhTextRange) -> [PartialNode]? {
    var nodes: [PartialNode] = []
    do {
      try enumerateContents(in: range) { _, node in
        nodes.append(node)
        return true  // continue
      }
    }
    catch { return nil }
    return nodes
  }
}
