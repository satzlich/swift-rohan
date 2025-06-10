// Copyright 2024-2025 Lie Yan

import Foundation

extension Bool {
  @inlinable @inline(__always)
  var intValue: Int { self ? 1 : 0 }
}
