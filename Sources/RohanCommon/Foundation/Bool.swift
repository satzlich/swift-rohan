// Copyright 2024-2025 Lie Yan

import Foundation

extension Bool {
  /** Returns integer value for the boolean; 1 for true, 0 for false. */
  @inlinable
  public var intValue: Int { self ? 1 : 0 }
}
