// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct AnalyzeTemplateUsesTests {
    @Test
    func sampleExpression() {
        let expressions = makeExpressions {
            makeHeading(level: 1) {
                "Demo of expressions"
            }
            makeParagraph {
                "Newton's second law:"
                makeEquation(isBlock: false) {
                    "a="
                    makeFraction(
                        numerator: { "F" },
                        denominator: { "m" }
                    )
                }
                ". Matrix representation of a "
                makeEmphasis { "complex " }
                "number:"
                makeEquation(isBlock: true) {
                    //
                }
            }
        }

        _ = expressions
    }

    @Test
    func sampleTemplates() {
    }
}
