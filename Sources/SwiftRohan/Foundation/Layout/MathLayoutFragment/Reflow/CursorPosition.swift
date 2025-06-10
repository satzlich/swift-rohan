// Copyright 2024-2025 Lie Yan

enum CursorPosition {
  /// cursor is placed after the upstream fragment
  case upstream
  /// cursor is placed in the middle between two fragments
  case middle
  /// cursor is placed before the downstream fragment
  case downstream
}
