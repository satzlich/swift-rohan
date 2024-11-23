// Copyright 2024 Lie Yan

import Foundation
import UnicodeMathClass

protocol MathFragment {
    var width: AbsLength { get }
    var height: AbsLength { get }
    var ascent: AbsLength { get }
    var descent: AbsLength { get }
    var italicsCorrection: AbsLength { get }
    var accentAttachment: AbsLength { get }

    var `class`: MathClass { get }

    var mathStyle: MathStyle { get }
    var limits: Limits { get }

    var isSpaced: Bool { get }
    var isTextLike: Bool { get }
}
