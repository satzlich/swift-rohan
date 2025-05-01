// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

extension UnicodeScalar {
  @inline(__always)
  var mathClass: MathClass? { UnicodeMathClass.mathClass(self) }
}
