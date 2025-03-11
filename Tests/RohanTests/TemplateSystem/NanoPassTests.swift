// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct NanoPassTests {
  static let square = TemplateSamples.square
  static let circle = TemplateSamples.circle
  static let ellipse = TemplateSamples.ellipse
  static let cdots = TemplateSamples.cdots
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
  static func testNanoPassDriver() {
    do {
      let input = [circle, ellipse, square, SOS] as [Template]
      let result = Nano.NanoPassDriver.process(input)
      #expect(result.isFailure())
    }
    do {
      let input = [circle, ellipse, square, cdots, SOS] as [Template]
      let result = Nano.NanoPassDriver.process(input)
      #expect(result.isSuccess())
    }
  }

  @Test
  static func testExtractTemplateCalls() {
    let input = [circle, ellipse, square, SOS] as [Template]
    let result = Nano.ExtractCalls.process(input)
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
    let A = Template(
      name: TemplateName("A"),
      parameters: [],
      body: [
        TextExpr("A"),
        ApplyExpr(TemplateName("B")),
        ApplyExpr(TemplateName("C")),
      ])
    let B = Template(
      name: TemplateName("B"),
      parameters: [],
      body: [
        TextExpr("B"),
        ApplyExpr(TemplateName("C")),
      ])
    let C = Template(
      name: TemplateName("C"),
      parameters: [],
      body: [TextExpr("C")])

    let D = Template(
      name: TemplateName("D"),
      parameters: [],
      body: [
        TextExpr("D"),
        ApplyExpr(TemplateName("E")),
      ])
    let E = Template(
      name: TemplateName("E"),
      parameters: [],
      body: [
        TextExpr("E"),
        ApplyExpr(TemplateName("D")),
      ])

    // annotated with uses
    typealias TemplateWithUses = Nano.AnnotatedTemplate<Nano.TemplateNames>

    let AA = TemplateWithUses(
      A,
      annotation: [
        TemplateName("B"),
        TemplateName("C"),
      ])
    let BB = TemplateWithUses(B, annotation: [TemplateName("C")])
    let CC = TemplateWithUses(C, annotation: [])
    let DD = TemplateWithUses(D, annotation: [TemplateName("E")])
    let EE = TemplateWithUses(E, annotation: [TemplateName("D")])

    // process

    do {
      let input = [
        BB, AA, CC,
      ]

      let result = Nano.TSortTemplates.process(input)
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

      let result = Nano.TSortTemplates.process(input)
      #expect(result.isFailure())
    }
  }

  @Test
  static func testInlineTemplateCalls() {
    // canonical

    let A = Template(
      name: TemplateName("A"),
      parameters: [],
      body: [
        TextExpr("A"),
        ApplyExpr(TemplateName("B")),
        ApplyExpr(TemplateName("C")),
      ])
    let B = Template(
      name: TemplateName("B"),
      parameters: [],
      body: [
        TextExpr("B"),
        ApplyExpr(TemplateName("C")),
      ])
    let C = Template(
      name: TemplateName("C"),
      parameters: [],
      body: [TextExpr("C")])

    // annotated with uses
    typealias TemplateWithUses = Nano.AnnotatedTemplate<Nano.TemplateNames>

    let AA = TemplateWithUses(
      A,
      annotation: [
        TemplateName("B"),
        TemplateName("C"),
      ])
    let BB = TemplateWithUses(B, annotation: [TemplateName("C")])
    let CC = TemplateWithUses(C, annotation: [])

    // process
    let input = [CC, BB, AA]
    let result = Nano.InlineCalls.process(input)

    #expect(result.isSuccess())

    func isFreeOfApply(_ template: Template) -> Bool {
      Espresso.countExpr(from: template.body, where: { $0.type == .apply }) == 0
    }

    for template in result.success()! {
      #expect(isFreeOfApply(template))
    }
  }

  @Test
  static func testUnnestContents_MergeNeighbours() {
    let A = Template(
      name: TemplateName("A"),
      parameters: [],
      body: [
        TextExpr("A"),
        ContentExpr([TextExpr("B"), ContentExpr([TextExpr("C")])]),
        ContentExpr([TextExpr("C")]),
      ])
    let B = Template(
      name: TemplateName("B"),
      parameters: [],
      body: [
        TextExpr("B"),
        ContentExpr([TextExpr("C")]),
      ])
    let C = Template(
      name: TemplateName("C"),
      parameters: [],
      body: [TextExpr("C")])

    let input = [A, B, C]
    guard let output = Nano.UnnestContents.process(input).success() else {
      Issue.record("UnnestContents failed")
      return
    }
    guard let output = Nano.MergeNeighbours.process(output).success() else {
      Issue.record("MergeNeighbours failed")
      return
    }

    for (template, ans) in zip(output, ["ABCC", "BC", "C"]) {
      let expressions = template.body
      #expect(expressions.count == 1)
      #expect(expressions[0].type == .text)
      #expect((expressions[0] as! TextExpr).string == ans)
    }
  }

  @Test
  static func testLocateNamelessVariables() {
    let templates = [square_idx, circle_idx, ellipse_idx, SOS_idx]

    let result = Nano.LocateUnnamedVariables.process(templates)

    guard let output = result.success() else {
      Issue.record("LocateNamelessVariables failed")
      return
    }

    #expect(output.count == 4)

    #expect(
      output[0].annotation == [
        0: [TreePath([.index(0)])]
      ])
    #expect(
      output[1].annotation == [
        0: [TreePath([.index(0)])],
        1: [TreePath([.index(3)])],
      ])
    #expect(
      output[2].annotation == [
        0: [
          TreePath([
            .index(0),
            .mathIndex(.numerator),
            .index(0),
          ])
        ],
        1: [
          TreePath([
            .index(2),
            .mathIndex(.numerator),
            .index(0),
          ])
        ],
      ])
    #expect(
      output[3].annotation == [
        0: [
          TreePath([.index(0)]),
          TreePath([.index(3)]),
          TreePath([.index(6)]),
        ]
      ])
  }

  @Test
  static func testConvertNamedVariables() {
    let foo =
      Template(
        name: TemplateName("foo"),
        parameters: [
          Identifier("x"),
          Identifier("y"),
          Identifier("z"),
        ],
        body: [
          VariableExpr("z"),
          TextExpr("="),
          VariableExpr("x"),
          TextExpr("+"),
          VariableExpr("y"),
        ])

    let input = [foo]
    guard
      let output = Nano.ConvertNamedVariables
        .process(input)
        .success()
    else {
      Issue.record("ConvertNamedVariables")
      return
    }
    #expect(output.count == 1)

    let body = output[0].body

    #expect(
      ContentExpr(body).prettyPrint() == """
        content
        ├ unnamedVariable 2
        ├ text "="
        ├ unnamedVariable 0
        ├ text "+"
        └ unnamedVariable 1
        """)
  }
}
