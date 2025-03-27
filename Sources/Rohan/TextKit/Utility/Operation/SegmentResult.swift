// Copyright 2024-2025 Lie Yan

/// Result of taking a segment of input node
enum SegmentResult<T> {
  /// empty segment
  case empty
  /// the whole of input node
  case full
  /// strict partial segment of input node
  case partial(T)
}
