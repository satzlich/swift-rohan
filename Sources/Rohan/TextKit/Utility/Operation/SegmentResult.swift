// Copyright 2024-2025 Lie Yan

enum SegmentResult<T> {
  /** the segment does not intersect with the range */
  case empty
  /** the whole segment is in the range */
  case full
  /** the segment is partially in the range */
  case partial(T)
}
