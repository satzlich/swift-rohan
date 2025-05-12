// Copyright 2024-2025 Lie Yan

import Foundation

extension Bool {
  @inline(__always) var intValue: Int { self ? 1 : 0 }
}
