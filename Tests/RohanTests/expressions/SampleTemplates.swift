// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation

struct SampleTemplates {
    static let square =
        Template(name: TemplateName("square")!,
                 parameters: [Identifier("x")!],
                 body: Content {
                     Variable("x")!
                     Scripts(superscript: { "2" })
                 })!

    static let circle =
        Template(name: TemplateName("circle")!,
                 parameters: [Identifier("x")!, Identifier("y")!],
                 body: Content {
                     Apply(TemplateName("square")!) { Variable("x")! }
                     "+"
                     Apply(TemplateName("square")!) { Variable("y")! }
                     "=1"
                 })!

    static let ellipse =
        Template(name: TemplateName("ellipse")!,
                 parameters: [Identifier("x")!, Identifier("y")!],
                 body: Content {
                     Fraction(
                         numerator: {
                             Apply(TemplateName("square")!) { Variable("x")! }
                         },
                         denominator: {
                             Apply(TemplateName("square")!) { Variable("a")! }
                         }
                     )
                     "+"
                     Fraction(
                         numerator: {
                             Apply(TemplateName("square")!) { Variable("y")! }
                         },
                         denominator: {
                             Apply(TemplateName("square")!) { Variable("b")! }
                         }
                     )
                     "=1"
                 })!
}
