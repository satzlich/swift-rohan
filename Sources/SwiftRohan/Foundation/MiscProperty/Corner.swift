// Copyright 2024-2025 Lie Yan

/// The four corners of a rectangle.
enum Corner {
  case topLeft, topRight, bottomLeft, bottomRight

  /// The opposite corner.
  func opposite() -> Corner {
    switch self {
    case .topLeft: return .bottomRight
    case .topRight: return .bottomLeft
    case .bottomLeft: return .topRight
    case .bottomRight: return .topLeft
    }
  }
}
