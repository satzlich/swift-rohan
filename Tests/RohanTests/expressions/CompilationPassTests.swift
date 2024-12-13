// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct CompilationPassTests {
    static let square = SampleTemplates.square
    static let circle = SampleTemplates.circle
    static let ellipse = SampleTemplates.ellipse

    @Test
    static func testAnalyseTemplateUses() {
        let input = [circle, ellipse, square] as [Template]
        let output = AnalyseTemplateUses().process(input)
        #expect(output.isSuccess())

        let templates = output.success()!
        #expect(templates[0].annotation == [TemplateName("square")!])
        #expect(templates[1].annotation == [TemplateName("square")!])
        #expect(templates[2].annotation == [])
    }

    @Test
    static func testSortTopologically() {
        let A = Template(name: TemplateName("A")!,
                         parameters: [],
                         body: Content {
                             "A"
                             Apply(TemplateName("B")!)
                             Apply(TemplateName("C")!)
                         })!
        let B = Template(name: TemplateName("B")!,
                         parameters: [],
                         body: Content {
                             "B"
                             Apply(TemplateName("C")!)
                         })!
        let C = Template(name: TemplateName("C")!,
                         parameters: [],
                         body: Content { "C" })!

        let D = Template(name: TemplateName("D")!,
                         parameters: [],
                         body: Content {
                             "D"
                             Apply(TemplateName("E")!)
                         })!
        let E = Template(name: TemplateName("E")!,
                         parameters: [],
                         body: Content {
                             "E"
                             Apply(TemplateName("D")!)
                         })!

        typealias TemplateWithUses = AnnotatedTemplate<TemplateUses>

        let AA = TemplateWithUses(A, annotation: [TemplateName("B")!,
                                                  TemplateName("C")!])
        let BB = TemplateWithUses(B, annotation: [TemplateName("C")!])
        let CC = TemplateWithUses(C, annotation: [])
        let DD = TemplateWithUses(D, annotation: [TemplateName("E")!])
        let EE = TemplateWithUses(E, annotation: [TemplateName("D")!])

        do {
            let input = [
                BB, AA, CC,
            ]

            let output = SortTopologically().process(input)
            #expect(output.isSuccess())

            let templates = output.success()!
            #expect(templates[0].name == TemplateName("C")!)
            #expect(templates[1].name == TemplateName("B")!)
            #expect(templates[2].name == TemplateName("A")!)

            // check first template
            #expect(ExpandAndCompact.isApplyFree(templates[0].canonical) == true)
            #expect(ExpandAndCompact.isApplyFree(templates[2].canonical) == false)
        }

        do {
            let input = [
                AA, BB, CC, DD, EE,
            ]

            let output = SortTopologically().process(input)
            #expect(output.isFailure())
        }
    }
}
