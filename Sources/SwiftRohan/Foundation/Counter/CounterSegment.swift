// Copyright 2024-2025 Lie Yan

/// A segment of `CountHolder`s that is delimited by `[begin, end]` (inclusive).
struct CounterSegment {
  let begin: CountHolder
  let end: CountHolder

  var isSingleton: Bool { begin === end }

  init(_ begin: CountHolder, _ end: CountHolder) {
    self.begin = begin
    self.end = end
  }

  init(_ holder: CountHolder) {
    self.begin = holder
    self.end = holder
  }
}
