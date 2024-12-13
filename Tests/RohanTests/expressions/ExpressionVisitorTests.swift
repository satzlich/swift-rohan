// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct ExpressionVisitorTests {
    let circle =
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

    let ellipse =
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
    func testAnalyseTemplateUses() {
        let output = AnalyseTemplateUses().process([circle, ellipse])

        #expect(output.isSuccess())

        guard let templates = output.success() else {
            #expect(Bool(false), "result should not be nil")
            return
        }

        #expect(templates[0].templateUses == [TemplateName("square")!])
        #expect(templates[1].templateUses == [])
    }

    @Test
    func testPlugins() {
        let applyCounter = ApplyCounter()
        let namedVariableCounter = NamedVariableCounter()
        let namelessVariable_OutOfRange_Counter =
            NamelessVariable_OutOfRange_Counter(parameterCount: 2)

        ExpressionUtils.applyPlugins(
            [
                applyCounter,
                namedVariableCounter,
                namelessVariable_OutOfRange_Counter,
            ],
            circle.body
        )

        #expect(applyCounter.count == 2)
        #expect(namedVariableCounter.count == 2)
        #expect(namelessVariable_OutOfRange_Counter.count == 0)
    }
}
