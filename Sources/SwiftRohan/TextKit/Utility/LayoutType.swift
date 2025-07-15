// Copyright 2024-2025 Lie Yan

enum LayoutType: UInt8 {
  case block
  case inline

  @inlinable @inline(__always)
  static func newlineBetween(_ lhs: LayoutType, _ rhs: LayoutType) -> Bool {
    if lhs == .inline && rhs == .inline {
      return false
    }
    else {
      return true
    }
  }
}
