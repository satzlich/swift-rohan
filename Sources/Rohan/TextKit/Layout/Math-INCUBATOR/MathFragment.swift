// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

protocol MathFragment {
    var fontSize: FontSize { get }

    // MARK: - Metrics

    var width: AbsLength { get }
    var height: AbsLength { get }
    var ascent: AbsLength { get }
    var descent: AbsLength { get }
    var italicsCorrection: AbsLength { get }
    var accentAttachment: AbsLength { get }

    // MARK: - Categories

    var clazz: MathClass { get }
    var limits: Limits { get }

    // MARK: - Flags

    /** Returns true if the fragment should be surrounded by spaces. */
    var isSpaced: Bool { get }

    /** Returns true if the fragment has text-like behavior. */
    var isTextLike: Bool { get }

    // MARK: - Draw

    func draw(at point: CGPoint, in context: CGContext)
}
