// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation

struct SampleTemplates {
    static let square =
        Template(name: TemplateName("square"),
                 parameters: [Identifier("x")],
                 body: Content {
                     Variable("x")
                     Scripts(superScript: { "2" })
                 })

    static let circle =
        Template(name: TemplateName("circle"),
                 parameters: [Identifier("x"), Identifier("y")],
                 body: Content {
                     Apply(TemplateName("square")) { Variable("x") }
                     "+"
                     Apply(TemplateName("square")) { Variable("y") }
                     "=1"
                 })

    static let ellipse =
        Template(name: TemplateName("ellipse"),
                 parameters: [Identifier("x"), Identifier("y")],
                 body: Content {
                     Fraction(
                         numerator: {
                             Apply(TemplateName("square")) { Variable("x") }
                         },
                         denominator: {
                             Apply(TemplateName("square")) { "a" }
                         }
                     )
                     "+"
                     Fraction(
                         numerator: {
                             Apply(TemplateName("square")) { Variable("y") }
                         },
                         denominator: {
                             Apply(TemplateName("square")) { "b" }
                         }
                     )
                     "=1"
                 })

    static let cdots =
        Template(name: TemplateName("cdots"),
                 parameters: [],
                 body: Content { "⋯" })

    /// Sum of squares
    static let SOS =
        Template(name: TemplateName("SOS"),
                 parameters: [Identifier("x")],
                 body: Content {
                     Variable("x")
                     Scripts(subScript: { "1" }, superScript: { "2" })
                     "+"
                     Variable("x")
                     Scripts(subScript: { "2" }, superScript: { "2" })
                     "+"
                     Apply(TemplateName("cdots"))
                     "+"
                     Variable("x")
                     Scripts(subScript: { "n" }, superScript: { "2" })
                 })

    // MARK: - Expanded

    static let circle_plain =
        Template(name: TemplateName("circle"),
                 parameters: [Identifier("x"), Identifier("y")],
                 body: Content {
                     Variable("x")
                     Scripts(superScript: { "2" })
                     "+"
                     Variable("y")
                     Scripts(superScript: { "2" })
                     "=1"
                 })

    static let ellipse_plain =
        Template(name: TemplateName("ellipse"),
                 parameters: [Identifier("x"), Identifier("y")],
                 body: Content {
                     Fraction(
                         numerator: {
                             Variable("x")
                             Scripts(superScript: { "2" })
                         },
                         denominator: {
                             "a"
                             Scripts(superScript: { "2" })
                         }
                     )
                     "+"
                     Fraction(
                         numerator: {
                             Variable("y")
                             Scripts(superScript: { "2" })
                         },
                         denominator: {
                             "b"
                             Scripts(superScript: { "2" })
                         }
                     )
                     "=1"
                 })

    static let SOS_plain =
        Template(name: TemplateName("SOS"),
                 parameters: [Identifier("x")],
                 body: Content {
                     Variable("x")
                     Scripts(subScript: { "1" }, superScript: { "2" })
                     "+"
                     Variable("x")
                     Scripts(subScript: { "2" }, superScript: { "2" })
                     "+⋯+"
                     Variable("x")
                     Scripts(subScript: { "n" }, superScript: { "2" })
                 })
}
