import Foundation
import UnicodeMathClass

extension UnicodeScalar {
  @inline(__always)
  var mathClass: MathClass? { UnicodeMathClass.mathClass(self) }
}
