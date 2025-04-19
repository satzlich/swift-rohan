// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

protocol MathFragment {
    // MARK: - Metrics

    var width: Double { get }
    var height: Double { get }
    var ascent: Double { get }
    var descent: Double { get }
    var italicsCorrection: Double { get }
    var accentAttachment: Double { get }

    // MARK: - Categories

    var clazz: MathClass { get }
    var limits: Limits { get }

    // MARK: - Flags

    /// Returns true if the fragment should be surrounded by spaces.
    var isSpaced: Bool { get }

    /// Returns true if the fragment has text-like behavior.
    var isTextLike: Bool { get }

    // MARK: - Draw

    func draw(at point: CGPoint, in context: CGContext)
}
