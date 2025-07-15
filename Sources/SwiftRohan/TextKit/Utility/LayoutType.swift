// Copyright 2024-2025 Lie Yan

enum LayoutType: UInt8, Codable, CaseIterable {
  /// (hard) block.
  case block
  case inline
  /// soft block
  case softBlock

  /// Returns true if a newline should be inserted between two layout types.
  @inlinable @inline(__always)
  static func isNewline(_ lhs: LayoutType, _ rhs: LayoutType) -> Bool {
    switch (lhs, rhs) {
    case (.block, _), (_, .block): true
    case (.softBlock, .softBlock): true
    case _: false
    }
  }
}
