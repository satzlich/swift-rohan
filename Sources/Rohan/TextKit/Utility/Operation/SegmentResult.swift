// Copyright 2024-2025 Lie Yan

/** Result of segmenting a node. */
enum SegmentResult<T> {
  /** empty segment */
  case empty
  /** the whole of input node */
  case full
  /** strictly partial segment of input node */
  case partial(T)
}
