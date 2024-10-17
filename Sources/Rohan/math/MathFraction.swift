// Copyright 2024 Lie Yan

import Foundation

final class MathFraction: MathExpression {
    let numerator: MathContent
    let denominator: MathContent

    init(_ numerator: MathContent, _ denominator: MathContent) {
        self.numerator = numerator
        self.denominator = denominator
    }
}
