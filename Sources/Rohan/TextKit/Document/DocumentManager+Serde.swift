// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension DocumentManager {
  /// Serialize the contents in the given range to JSON data.
  /// - Returns: The JSON data, or nil if the range is invalid.
  func jsonData(for range: RhTextRange) -> Data? {
    // obtain nodes in the range
    guard let nodes = mapContents(in: range, { $0 }) else { return nil }
    // perform serialization
    let encoder = JSONEncoder()
    #if DEBUG
    encoder.outputFormatting = .sortedKeys
    #endif
    return try? encoder.encode(nodes)
  }

  /// Serialize the contents in the given range to a lossy string.
  /// -Returns: The lossy string, or nil if the range is invalid.
  func stringify(for range: RhTextRange) -> BigString? {
    // obtain nodes in the range
    guard let nodes = mapContents(in: range, { $0 }) else { return nil }
    // perform serialization
    return StringifyUtils.stringify(nodes)
  }
}
