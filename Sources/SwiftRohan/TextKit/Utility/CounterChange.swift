// Copyright 2024-2025 Lie Yan

enum CounterChange {
  /// No change to the counter segment.
  case unchanged
  /// Brand new counter segment.
  case newAdded(CounterSegment)
  /// A segment is joined to the interior of the counter segment.
  case interiorAdded(CounterSegment)
  /// A segment is added to the left of the counter segment.
  case leftAdded(CounterSegment)
  /// A segment is added to the right of the counter segment.
  case rightAdded(CounterSegment)
  /// Whole counter segment is removed.
  case allRemoved
  /// A segment is removed from the interior of the counter segment.
  case interiorRemoved(CounterSegment)
  /// A segment is removed from the left of the counter segment.
  case leftRemoved(CounterSegment)
  /// A segment is removed from the right of the counter segment.
  case rightRemoved(CounterSegment)
  /// A segment is replaced by another segment.
  case replaced(CounterSegment)
}
