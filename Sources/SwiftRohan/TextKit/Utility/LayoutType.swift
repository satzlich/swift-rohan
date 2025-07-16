// Copyright 2024-2025 Lie Yan

enum LayoutType: UInt8, Codable, CaseIterable {
  case inline
  /// hard block.
  case hardBlock
  /// soft block
  case softBlock

  /// Returns true if a newline should be inserted between two layout types.
  @inlinable @inline(__always)
  static func isNewline(_ lhs: LayoutType, _ rhs: LayoutType) -> Bool {
    switch (lhs, rhs) {
    case (.hardBlock, _), (_, .hardBlock): true
    case (.softBlock, .softBlock): true
    case _: false
    }
  }

  @inlinable @inline(__always)
  var mayEmitBlock: Bool {
    switch self {
    case .hardBlock: true
    case .softBlock: true
    case .inline: false
    }
  }
}
