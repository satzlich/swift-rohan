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

  /// Concatenate a collection of `CounterSegment`s.
  /// - Returns: a counter segment that encompasses all the segments in the collection,
  ///     or `nil` if the collection is empty.
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

  /// Insert `segment` before `next` segment.
  static func insert(_ segment: CounterSegment, before next: CounterSegment) {
    if let previous = next.begin.previous {
      CountHolder.connect(previous, segment.begin)
      CountHolder.connect(segment.end, next.begin)
    }
    else {
      // `next` is the first segment, so we can just insert `segment` before it.
      CountHolder.connect(segment.end, next.begin)
    }
  }

  /// Insert `segment` after `previous` segment.
  static func insert(_ segment: CounterSegment, after previous: CounterSegment) {
    if let next = previous.end.next {
      CountHolder.connect(previous.end, segment.begin)
      CountHolder.connect(segment.end, next)
    }
    else {
      // `previous` is the last segment, so we can just insert `segment` after it.
      CountHolder.connect(previous.end, segment.begin)
    }
  }
}
