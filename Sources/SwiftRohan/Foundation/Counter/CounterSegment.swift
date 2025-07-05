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

extension CounterSegment {
  static func concate(
    contentsOf segments: some Collection<CounterSegment>
  ) -> CounterSegment? {
    guard let first = segments.first else { return nil }

    var i = first

    for segment in segments.dropFirst() {
      CountHolder.connect(i.end, segment.begin)
      i = segment
    }
    return CounterSegment(first.begin, i.end)
  }

  static func insert(_ segment: CounterSegment, before next: CounterSegment) {
    preconditionFailure("TODO: implement CounterSegment.insert(before:)")
  }

  static func insert(_ segment: CounterSegment, after previous: CounterSegment) {
    preconditionFailure("TODO: implement CounterSegment.insert(after:)")
  }
}
