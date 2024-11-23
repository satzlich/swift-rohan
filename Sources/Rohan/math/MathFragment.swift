// Copyright 2024 Lie Yan

import Foundation
import UnicodeMathClass

protocol MathFragment {
    var width: AbsLength { get }
    var height: AbsLength { get }
    var ascent: AbsLength { get }
    var descent: AbsLength { get }

    var `class`: MathClass { get }
}
