// Copyright 2024-2025 Lie Yan

enum LayoutType: UInt8, Codable, CaseIterable {
  case block
  case inline

  /// Returns true if a newline should be inserted between two layout types.
  @inlinable @inline(__always)
  static func isNewline(_ lhs: LayoutType, _ rhs: LayoutType) -> Bool {
    switch (lhs, rhs) {
    case (.inline, .inline): false
    case _: true
    }
  }
}
