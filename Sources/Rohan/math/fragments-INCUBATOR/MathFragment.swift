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
    var limits: Limits { get }

    /// Indicates whether the fragment should be surrounded by spaces.
    var isSpaced: Bool { get }

    /// Indicates whether the fragment has text-like behavior.
    var isTextLike: Bool { get }
}
