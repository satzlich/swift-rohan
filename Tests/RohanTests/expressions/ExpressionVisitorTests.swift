// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct ExpressionVisitorTests {
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
                     Apply.make(TemplateName("square")!) { Variable("x")! }
                     "+"
                     Apply.make(TemplateName("square")!) { Variable("y")! }
                     "=1"
                 })!

    static let ellipse =
        Template(name: TemplateName("ellipse")!,
                 parameters: [Identifier("x")!, Identifier("y")!],
                 body: Content {
                     Fraction(
                         numerator: {
                             Apply.make(TemplateName("square")!) { Variable("x")! }
                         },
                         denominator: {
                             Apply.make(TemplateName("square")!) { Variable("a")! }
                         }
                     )
                     "+"
                     Fraction(
                         numerator: {
                             Apply.make(TemplateName("square")!) { Variable("y")! }
                         },
                         denominator: {
                             Apply.make(TemplateName("square")!) { Variable("b")! }
                         }
                     )
                     "=1"
                 })!

    @Test
    static func testAnalyseTemplateUses() {
        let input = [circle, ellipse, square] as [Template]
        let output = AnalyseTemplateUses().process(input)
        #expect(output.isSuccess())

        let templates = output.success()!
        #expect(templates[0].templateUses == [TemplateName("square")!])
        #expect(templates[1].templateUses == [TemplateName("square")!])
        #expect(templates[2].templateUses == [])
    }

    @Test
    static func testSortTopologically() {
        let A = Template(name: TemplateName("A")!, parameters: [],
                         body: Content {
                             "A"
                             Apply(TemplateName("B")!)
                             Apply(TemplateName("C")!)
                         })!
        let B = Template(name: TemplateName("B")!, parameters: [],
                         body: Content {
                             "B"
                             Apply(TemplateName("C")!)
                         })!
        let C = Template(name: TemplateName("C")!, parameters: [],
                         body: Content { "C" })!

        let input = [
            TemplateWithUses(template: B, templateUses: [TemplateName("C")!]),
            TemplateWithUses(template: A, templateUses: [TemplateName("B")!, TemplateName("C")!]),
            TemplateWithUses(template: C, templateUses: []),
        ]

        let output = SortTopologically().process(input)
        #expect(output.isSuccess())

        let templates = output.success()!
        #expect(templates[0].name == TemplateName("C")!)
        #expect(templates[1].name == TemplateName("B")!)
        #expect(templates[2].name == TemplateName("A")!)
    }

    @Test
    static func testPlugins() {
        let fused = Espresso.fusePlugins(
            Espresso.ApplyCounter(),
            Espresso.VariableCounter(),
            Espresso.ParticularVariableCounter(Identifier("x")!)
        )

        let result = Espresso.applyPlugin(fused, circle.body)

        let (
            nameApplyCounter,
            namedVariableCounter,
            xVariableCounter
        ) = Espresso.unfusePlugins(result)

        #expect(nameApplyCounter.count == 2)
        #expect(namedVariableCounter.count == 2)
        #expect(xVariableCounter.count == 1)
    }
}
