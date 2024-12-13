// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct ExpressionVisitorTests {
    static let circle =
        Template(name: TemplateName("circle")!,
                 parameters: [Identifier("x")!, Identifier("y")!],
                 body: Content {
                     Apply(
                         TemplateName("square")!,
                         arguments: {
                             Content {
                                 Variable("x")!
                             }
                         }
                     )
                     "+"
                     Apply(
                         TemplateName("square")!,
                         arguments: {
                             Content {
                                 Variable("y")!
                             }
                         }
                     )
                     "=1"
                 })!

    static let ellipse =
        Template(name: TemplateName("ellipse")!,
                 parameters: [Identifier("x")!, Identifier("y")!],
                 body: Content {
                     Fraction(
                         numerator: {
                             Variable("x")!
                             Scripts(superscript: { "2" })
                         },
                         denominator: {
                             "a"
                             Scripts(superscript: { "2" })
                         }
                     )
                     "+"
                     Fraction(
                         numerator: {
                             Variable("x")!
                             Scripts(superscript: { "2" })
                         },
                         denominator: {
                             "b"
                             Scripts(superscript: { "2" })
                         }
                     )
                     "=1"
                 })!

    @Test
    static func testAnalyseTemplateUses() {
        let output = AnalyseTemplateUses().process([circle, ellipse])
        #expect(output.isSuccess())

        let templates = output.success()!
        #expect(templates[0].templateUses == [TemplateName("square")!])
        #expect(templates[1].templateUses == [])
    }

    @Test
    static func testPlugins() {
        let fusedPlugin = ExpressionUtils.fuse(
            ExpressionUtils.ApplyCounter(),
            ExpressionUtils.VariableCounter(),
            ExpressionUtils.ParticularVariableCounter(Identifier("x")!)
        )

        let result = ExpressionUtils.applyPlugin(fusedPlugin, circle.body)

        let (
            nameApplyCounter,
            namedVariableCounter,
            xVariableCounter
        ) = ExpressionUtils.unfuse(result)

        #expect(nameApplyCounter.count == 2)
        #expect(namedVariableCounter.count == 2)
        #expect(xVariableCounter.count == 1)
    }
}
