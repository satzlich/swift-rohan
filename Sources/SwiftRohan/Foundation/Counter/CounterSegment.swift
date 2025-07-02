// Copyright 2024-2025 Lie Yan

/// A segment of `CountHolder`s that is delimited by `[begin, end]` (inclusive).
struct CounterSegment: Equatable, Hashable {
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

  static func == (lhs: CounterSegment, rhs: CounterSegment) -> Bool {
    lhs.begin === rhs.begin && lhs.end === rhs.end
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(begin))
    hasher.combine(ObjectIdentifier(end))
  }
}
