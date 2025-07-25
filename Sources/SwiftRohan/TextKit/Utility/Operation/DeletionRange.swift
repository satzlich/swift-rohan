import Foundation

struct DeletionRange {
  let textRange: RhTextRange
  /// True if the range should be deleted immediately; otherwise, deletion can be
  /// delayed. In the latter case, the caller can choose to highlight the range to
  /// be deleted as a signal to the user.
  let isImmediate: Bool

  init(_ textRange: RhTextRange, isImmediate: Bool) {
    self.textRange = textRange
    self.isImmediate = isImmediate
  }
}

extension DeletionRange: CustomStringConvertible {
  var description: String {
    "(\(textRange), \(isImmediate ? "immediate" : "delayed"))"
  }
}
