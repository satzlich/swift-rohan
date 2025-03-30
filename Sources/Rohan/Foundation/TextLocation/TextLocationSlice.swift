// Copyright 2024-2025 Lie Yan

import Foundation

/// Tail slice of TextLocation
struct TextLocationSlice {
  /// The indices except the last
  let indices: ArraySlice<RohanIndex>
  /// The last index
  let offset: Int

  init(_ indices: ArraySlice<RohanIndex>, _ offset: Int) {
    self.indices = indices
    self.offset = offset
  }

  func dropFirst(_ k: Int) -> TextLocationSlice {
    precondition(k <= indices.count)
    return TextLocationSlice(indices.dropFirst(k), offset)
  }

  func dropFirst() -> TextLocationSlice {
    dropFirst(1)
  }

  var count: Int { indices.count + 1 }
}

extension TextLocation {
  var asTextLocationSlice: TextLocationSlice {
    TextLocationSlice(ArraySlice(indices), offset)
  }
}
