// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct NanoPassTests {
    static let square = TemplateSamples.square
    static let circle = TemplateSamples.circle
    static let ellipse = TemplateSamples.ellipse
    static let SOS = TemplateSamples.SOS
    //
    static let circle_0 = TemplateSamples.circle_0
    static let ellipse_0 = TemplateSamples.ellipse_0
    static let SOS_0 = TemplateSamples.SOS_0
    //
    static let square_idx = TemplateSamples.square_idx
    static let circle_idx = TemplateSamples.circle_idx
    static let ellipse_idx = TemplateSamples.ellipse_idx
    static let SOS_idx = TemplateSamples.SOS_idx

    @Test
    static func testExtractTemplateCalls() {
        let input = [circle, ellipse, square, SOS] as [Template]
        let result = Nano.ExtractTemplateCalls().process(input)
        #expect(result.isSuccess())

        let output = result.success()!
        #expect(output[0].annotation == [TemplateName("square")])
        #expect(output[1].annotation == [TemplateName("square")])
        #expect(output[2].annotation == [])
        #expect(output[3].annotation == [TemplateName("cdots")])
    }

    @Test
    static func testTSortTemplates() {
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
        typealias TemplateWithUses = Nano.AnnotatedTemplate<Nano.TemplateCalls>

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

            let result = Nano.TSortTemplates().process(input)
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

            let result = Nano.TSortTemplates().process(input)
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
        typealias TemplateWithUses = Nano.AnnotatedTemplate<Nano.TemplateCalls>

        let AA = TemplateWithUses(A, annotation: [TemplateName("B"),
                                                  TemplateName("C")])
        let BB = TemplateWithUses(B, annotation: [TemplateName("C")])
        let CC = TemplateWithUses(C, annotation: [])

        // process
        let input = [CC, BB, AA]
        let result = Nano.InlineTemplateCalls().process(input)

        #expect(result.isSuccess())
        for template in result.success()! {
            #expect(Espresso.count({ $0.type == .apply }, in: template.body) == 0)
        }
    }

    @Test
    static func testUnnestContents_MergeNeighbours() {
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
        guard let output = Nano.UnnestContents().process(input).success() else {
            #expect(Bool(false))
            return
        }
        guard let output = Nano.MergeNeighbours().process(output).success() else {
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

    @Test
    static func testLocateVariables() {
        let templates = [square, circle_0, ellipse_0, SOS_0]

        let result = Nano.LocateVariables().process(templates)

        guard let output = result.success() else {
            #expect(Bool(false))
            return
        }

        #expect(output.count == 4)

        #expect(output[0].annotation ==
            [
                Identifier("x"): [TreePath([.arrayIndex(0)])],
            ])
        #expect(output[1].annotation ==
            [
                Identifier("x"): [TreePath([.arrayIndex(0)])],
                Identifier("y"): [TreePath([.arrayIndex(3)])],
            ])
        #expect(output[2].annotation ==
            [
                Identifier("x"): [TreePath([.arrayIndex(0),
                                            .mathIndex(.numerator),
                                            .arrayIndex(0)])],
                Identifier("y"): [TreePath([.arrayIndex(2),
                                            .mathIndex(.numerator),
                                            .arrayIndex(0)])],
            ])
        #expect(output[3].annotation ==
            [
                Identifier("x"): [
                    TreePath([.arrayIndex(0)]),
                    TreePath([.arrayIndex(3)]),
                    TreePath([.arrayIndex(6)]),
                ],
            ])
    }

    @Test
    static func testLocateNamelessVariables() {
        let templates = [square_idx, circle_idx, ellipse_idx, SOS_idx]

        let result = Nano.LocateNamelessVariables().process(templates)

        guard let output = result.success() else {
            #expect(Bool(false))
            return
        }

        #expect(output.count == 4)

        #expect(output[0].annotation ==
            [
                0: [TreePath([.arrayIndex(0)])],
            ])
        #expect(output[1].annotation ==
            [
                0: [TreePath([.arrayIndex(0)])],
                1: [TreePath([.arrayIndex(3)])],
            ])
        #expect(output[2].annotation ==
            [
                0: [TreePath([.arrayIndex(0),
                              .mathIndex(.numerator),
                              .arrayIndex(0)])],
                1: [TreePath([.arrayIndex(2),
                              .mathIndex(.numerator),
                              .arrayIndex(0)])],
            ])
        #expect(output[3].annotation ==
            [
                0: [
                    TreePath([.arrayIndex(0)]),
                    TreePath([.arrayIndex(3)]),
                    TreePath([.arrayIndex(6)]),
                ],
            ])
    }

    @Test
    static func testEliminateVariableName() {
        let foo =
            Template(name: TemplateName("foo"),
                     parameters: [
                         Identifier("x"),
                         Identifier("y"),
                         Identifier("z"),
                     ],
                     body: Content {
                         Variable("z")
                         "="
                         Variable("x")
                         "+"
                         Variable("y")
                     })

        let input = [foo]
        guard
            let output = Nano.EliminateVariableName()
                .process(input)
                .success()
        else {
            #expect(Bool(false))
            return
        }
        #expect(output.count == 1)

        let body = output[0].body

        #expect(body == Content {
            NamelessVariable(2)
            "="
            NamelessVariable(0)
            "+"
            NamelessVariable(1)
        })
    }
}
