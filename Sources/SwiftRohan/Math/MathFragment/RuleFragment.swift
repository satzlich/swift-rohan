// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

struct RuleFragment: MathFragment {
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    // MARK: - Metrics

    let width: Double
    let height: Double
    var ascent: Double { height / 2 }
    var descent: Double { height / 2 }
    var italicsCorrection: Double { 0 }
    var accentAttachment: Double { width / 2 }

    // MARK: - Cetegories

    var clazz: MathClass { .Normal }
    var limits: Limits { .never }

    // MARK: - Flags

    var isSpaced: Bool { false }
    var isTextLike: Bool { false }

    // MARK: - Draw

    func draw(at point: CGPoint, in context: CGContext) {
        let rect = CGRect(x: point.x, y: point.y - height / 2,
                          width: width, height: height)
        context.fill(rect)
    }
}
