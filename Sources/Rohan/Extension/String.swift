// Copyright 2024-2025 Lie Yan

import Foundation

extension String {
  @inline(__always) var length: Int { utf16.count }
}
