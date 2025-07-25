import Foundation
import UnicodeMathClass

extension MathClass {
  /// True if the class is deemed variable.
  /// - Note: the policy may change in the future. `Vary` is always deemed variable.
  var isVariable: Bool {
    self == .Vary || self == .Binary
  }
}
