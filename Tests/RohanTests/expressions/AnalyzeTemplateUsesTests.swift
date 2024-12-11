// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct AnalyzeTemplateUsesTests {
    func sampleExpression() {
        _ = Content {
            Heading(level: 1) {
                "Demo of expressions"
            }
            Paragraph {
                "Pythogorean equation:"
                // a^2 + b^2 = c^2
                Equation(isBlock: true) {
                    "a"
                    Scripts(superscript: { "2" })
                    "+b"
                    Scripts(superscript: { "2" })
                    "=c"
                    Scripts(superscript: { "2" })
                }
                "Newton's law:"
                // a = F/m
                Equation(isBlock: true) {
                    "a="
                    Fraction(
                        numerator: { "F" },
                        denominator: { "m" }
                    )
                }
                "Matrix representation of a "
                Emphasis { "complex " }
                "number:"
                // a+ib <-> [[a, -b], [b, a]]
                Equation(isBlock: false) {
                    "a+ib"
                    Apply(Identifier("leftrightarrow")!)
                    Matrix {
                        MatrixRow {
                            Content { "a" }
                            Content { "-b" }
                        }
                        MatrixRow {
                            Content { "b" }
                            Content { "a" }
                        }
                    }!
                }
            }
        }
    }
}
