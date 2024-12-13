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
}
