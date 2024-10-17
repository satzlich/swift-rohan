// Copyright 2024 Lie Yan

import Foundation

final class MathFraction: MathExpression {
    let numerator: Content
    let denominator: Content

    init(_ numerator: Content, _ denominator: Content) {
        self.numerator = numerator
        self.denominator = denominator
    }
}
