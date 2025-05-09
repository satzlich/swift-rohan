// Copyright 2024-2025 Lie Yan

protocol ColumnAlignmentProvider {
  func get(_ index: Int) -> FixedAlignment
}

struct FixedColumnAlignmentProvider: ColumnAlignmentProvider {
  let alignment: FixedAlignment

  init(_ alignment: FixedAlignment) {
    self.alignment = alignment
  }

  func get(_ index: Int) -> FixedAlignment {
    return alignment
  }
}

struct AlternateColumnAlignmentProvider: ColumnAlignmentProvider {
  func get(_ index: Int) -> FixedAlignment {
    return index % 2 == 0 ? .end : .start
  }
}
