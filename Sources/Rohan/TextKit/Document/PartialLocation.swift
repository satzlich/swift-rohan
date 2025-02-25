// Copyright 2024-2025 Lie Yan

import Foundation

struct PartialLocation {
  let indices: ArraySlice<RohanIndex>
  let offset: Int

  init(_ indices: ArraySlice<RohanIndex>, _ offset: Int) {
    self.indices = indices
    self.offset = offset
  }

  func dropFirst(_ k: Int) -> PartialLocation {
    precondition(k <= indices.count)
    return PartialLocation(indices.dropFirst(k), offset)
  }

  func dropFirst() -> PartialLocation {
    dropFirst(1)
  }

  var count: Int { indices.count + 1 }
}
