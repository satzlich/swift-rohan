// Copyright 2024-2025 Lie Yan

enum SegmentResult<T> {
  case empty  // none may conflict with Optional.none and cause unexpected behavior
  case full
  case partial(T)
}
