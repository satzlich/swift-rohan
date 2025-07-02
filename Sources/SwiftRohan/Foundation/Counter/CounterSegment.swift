// Copyright 2024-2025 Lie Yan

/// A segment of `CountHolder`s that is delimited by `[begin, end]` (inclusive).
struct CounterSegment {
  let begin: CountHolder
  let end: CountHolder

  var isSingleton: Bool { begin === end }
}
