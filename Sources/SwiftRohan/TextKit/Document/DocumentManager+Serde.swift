import Foundation
import _RopeModule

extension DocumentManager {
  /// Serialize the contents in the given range to JSON data.
  /// - Returns: The JSON data, or nil if the range is invalid.
  func jsonData(for range: RhTextRange) -> Data? {
    // obtain nodes in the range
    guard let nodes: Array<PartialNode> = mapContents(in: range, { $0 }) else {
      return nil
    }
    // perform serialization
    let encoder = JSONEncoder()
    #if DEBUG
    encoder.outputFormatting = .sortedKeys
    #endif
    return try? encoder.encode(nodes)
  }
}
