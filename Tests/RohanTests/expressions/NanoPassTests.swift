// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct NanoPassTests {
    static let square = SampleTemplates.square
    static let circle = SampleTemplates.circle
    static let ellipse = SampleTemplates.ellipse

    @Test
    static func testAnalyseTemplateUses() {
        let input = [circle, ellipse, square] as [Template]
        let result = Nano.ExtractTemplateCalls().process(input: input)
        #expect(result.isSuccess())

        let output = result.success()!
        #expect(output[0].annotation == [TemplateName("square")])
        #expect(output[1].annotation == [TemplateName("square")])
        #expect(output[2].annotation == [])
    }

    @Test
    static func testSortTopologically() {
        // canonical
        let A = Template(name: TemplateName("A"),
                         parameters: [],
                         body: Content {
                             "A"
                             Apply(TemplateName("B"))
                             Apply(TemplateName("C"))
                         })
        let B = Template(name: TemplateName("B"),
                         parameters: [],
                         body: Content {
                             "B"
                             Apply(TemplateName("C"))
                         })
        let C = Template(name: TemplateName("C"),
                         parameters: [],
                         body: Content { "C" })

        let D = Template(name: TemplateName("D"),
                         parameters: [],
                         body: Content {
                             "D"
                             Apply(TemplateName("E"))
                         })
        let E = Template(name: TemplateName("E"),
                         parameters: [],
                         body: Content {
                             "E"
                             Apply(TemplateName("D"))
                         })

        // annotated with uses
        typealias TemplateWithUses = AnnotatedTemplate<TemplateCalls>

        let AA = TemplateWithUses(A, annotation: [TemplateName("B"),
                                                  TemplateName("C")])
        let BB = TemplateWithUses(B, annotation: [TemplateName("C")])
        let CC = TemplateWithUses(C, annotation: [])
        let DD = TemplateWithUses(D, annotation: [TemplateName("E")])
        let EE = TemplateWithUses(E, annotation: [TemplateName("D")])

        // process

        do {
            let input = [
                BB, AA, CC,
            ]

            let result = Nano.SortTopologically().process(input: input)
            #expect(result.isSuccess())

            let output = result.success()!
            #expect(output[0].name == TemplateName("C"))
            #expect(output[1].name == TemplateName("B"))
            #expect(output[2].name == TemplateName("A"))

            #expect(output[0].annotation.isEmpty == true)
            #expect(output[2].annotation.isEmpty == false)
        }

        do {
            let input = [
                AA, BB, CC, DD, EE,
            ]

            let result = Nano.SortTopologically().process(input: input)
            #expect(result.isFailure())
        }
    }

    @Test
    static func testInlineTemplateCalls() {
        // canonical

        let A = Template(name: TemplateName("A"),
                         parameters: [],
                         body: Content {
                             "A"
                             Apply(TemplateName("B"))
                             Apply(TemplateName("C"))
                         })
        let B = Template(name: TemplateName("B"),
                         parameters: [],
                         body: Content {
                             "B"
                             Apply(TemplateName("C"))
                         })
        let C = Template(name: TemplateName("C"),
                         parameters: [],
                         body: Content { "C" })

        // annotated with uses
        typealias TemplateWithUses = AnnotatedTemplate<TemplateCalls>

        let AA = TemplateWithUses(A, annotation: [TemplateName("B"),
                                                  TemplateName("C")])
        let BB = TemplateWithUses(B, annotation: [TemplateName("C")])
        let CC = TemplateWithUses(C, annotation: [])

        // process
        let input = [CC, BB, AA]
        let result = Nano.InlineTemplateCalls().process(input: input)

        #expect(result.isSuccess())
        for template in result.success()! {
            #expect(Espresso.count({ $0.type == .apply }, in: template.body) == 0)
        }
    }

    @Test
    static func testUnnestAndMerge() {
        let A = Template(name: TemplateName("A"),
                         parameters: [],
                         body: Content {
                             "A"
                             Content {
                                 "B"
                                 Content { "C" }
                             }
                             Content { "C" }
                         })
        let B = Template(name: TemplateName("B"),
                         parameters: [],
                         body: Content {
                             "B"
                             Content { "C" }
                         })
        let C = Template(name: TemplateName("C"),
                         parameters: [],
                         body: Content { "C" })

        let input = [A, B, C]
        guard let output = Nano.UnnestContents().process(input: input).success() else {
            #expect(Bool(false))
            return
        }
        guard let output = Nano.MergeNeighbours().process(input: output).success() else {
            #expect(Bool(false))
            return
        }

        for (template, ans) in zip(output, ["ABCC", "BC", "C"]) {
            let expression = template.body.expressions
            #expect(expression.count == 1)
            #expect(expression[0].type == .text)
            #expect(expression[0].unwrapText()!.string == ans)
        }
    }
}
