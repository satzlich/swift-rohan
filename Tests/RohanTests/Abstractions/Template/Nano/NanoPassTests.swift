import Foundation
import Testing

@testable import SwiftRohan

struct NanoPassTests {
  let square = TemplateSamples.square
  let circle = TemplateSamples.circle
  let ellipse = TemplateSamples.ellipse
  let cdots = TemplateSamples.cdots
  let SOS = TemplateSamples.SOS
  //
  let square_idx = TemplateSamples.square_idx
  let circle_idx = TemplateSamples.circle_idx
  let ellipse_idx = TemplateSamples.ellipse_idx
  let SOS_idx = TemplateSamples.SOS_idx

  private func prettyPrint(_ template: Template) -> String {
    ContentExpr(template.body).prettyPrint()
  }

  @Test
  func testNanoPassDriver() {
    do {
      let input = [circle, ellipse, square, SOS] as Array<Template>
      let result = Nano.NanoPassDriver.process(input)
      #expect(result.isFailure)
    }
    do {
      let input = [circle, ellipse, square, cdots, SOS] as Array<Template>
      let result = Nano.NanoPassDriver.process(input)
      #expect(result.isSuccess)
    }
  }

  @Test
  func testCheckWellFormedness() {
    let erroneous = [
      Template(
        name: "square", parameters: ["x"],
        body: [
          AttachExpr(nuc: [VariableExpr("y", .inline)], sup: [TextExpr("2")])
        ],
        layoutType: .inline)
    ]
    let result = Nano.CheckWellFormedness.process(erroneous)
    #expect(result.isFailure)
  }

  @Test
  func testExtractCalls() {
    let input = [circle, ellipse, square, SOS] as Array<Template>
    let result = Nano.ExtractCalls.process(input)
    #expect(result.isSuccess)

    let output = result.success()!
    #expect(output[0].annotation == [TemplateName("square")])
    #expect(output[1].annotation == [TemplateName("square")])
    #expect(output[2].annotation == [])
    #expect(output[3].annotation == [TemplateName("cdots")])
  }

  @Test
  func testCheckDanglingCalls() {
    let erroneous: Nano.CheckDanglingCalls.Input = [
      .init(
        Template(
          name: "a", body: [ApplyExpr("b")],
          layoutType: .inline),
        annotation: [TemplateName("b")])
    ]
    let result = Nano.CheckDanglingCalls.process(erroneous)
    #expect(result.isFailure)
  }

  @Test
  func testTSortTemplates() {
    // canonical
    let A = Template(
      name: "A", body: [TextExpr("A"), ApplyExpr("B"), ApplyExpr("C")],
      layoutType: .inline)
    let B = Template(
      name: "B", body: [TextExpr("B"), ApplyExpr("C")],
      layoutType: .inline)
    let C = Template(
      name: "C", body: [TextExpr("C")],
      layoutType: .inline)
    let D = Template(
      name: "D", body: [TextExpr("D"), ApplyExpr("E")],
      layoutType: .inline)
    let E = Template(
      name: "E", body: [TextExpr("E"), ApplyExpr("D")],
      layoutType: .inline)

    // annotated with uses
    typealias TemplateWithUses = Nano.TSortTemplates.Input.Element

    let AA = TemplateWithUses(A, annotation: [TemplateName("B"), TemplateName("C")])
    let BB = TemplateWithUses(B, annotation: [TemplateName("C")])
    let CC = TemplateWithUses(C, annotation: [])
    let DD = TemplateWithUses(D, annotation: [TemplateName("E")])
    let EE = TemplateWithUses(E, annotation: [TemplateName("D")])

    // process

    do {
      let input = [BB, AA, CC]

      let result = Nano.TSortTemplates.process(input)
      #expect(result.isSuccess)

      let output = result.success()!
      #expect(output[0].name == TemplateName("C"))
      #expect(output[1].name == TemplateName("B"))
      #expect(output[2].name == TemplateName("A"))

      #expect(output[0].annotation.isEmpty == true)
      #expect(output[2].annotation.isEmpty == false)
    }

    do {
      let input = [AA, BB, CC, DD, EE]
      let result = Nano.TSortTemplates.process(input)
      #expect(result.isFailure)
    }
  }

  @Test
  func testInlineCalls() {
    // canonical

    let A = Template(
      name: "A", body: [TextExpr("A"), ApplyExpr("B"), ApplyExpr("C")],
      layoutType: .inline)
    let B = Template(
      name: "B", body: [TextExpr("B"), ApplyExpr("C")],
      layoutType: .inline)
    let C = Template(
      name: "C", body: [TextExpr("C")],
      layoutType: .inline)

    // annotated with uses
    typealias TemplateWithUses = Nano.InlineCalls.Input.Element

    let AA = TemplateWithUses(A, annotation: [TemplateName("B"), TemplateName("C")])
    let BB = TemplateWithUses(B, annotation: [TemplateName("C")])
    let CC = TemplateWithUses(C, annotation: [])

    // process
    let input = [CC, BB, AA]
    let result = Nano.InlineCalls.process(input)

    #expect(result.isSuccess)

    func isFreeOfApply(_ template: Template) -> Bool {
      NanoUtils.countExpr(from: template.body, where: { $0.type == .apply }) == 0
    }

    for template in result.success()! {
      #expect(isFreeOfApply(template))
    }
  }

  @Test
  func testUnnestContents_MergeNeighbours() {
    let A = Template(
      name: "A",
      body: [
        TextExpr("A"),
        ContentExpr([TextExpr("B"), ContentExpr([TextExpr("C")])]),
        ContentExpr([TextExpr("C")]),
      ],
      layoutType: .inline)
    let B = Template(
      name: "B", body: [TextExpr("B"), ContentExpr([TextExpr("C")])],
      layoutType: .inline)
    let C = Template(
      name: "C", body: [TextExpr("C")],
      layoutType: .inline)
    let D = Template(
      name: "D",
      body: [
        TextStylesExpr(.emph, [TextExpr("D")]), TextStylesExpr(.emph, [TextExpr("E")]),
      ],
      layoutType: .inline)

    let input = [A, B, C, D]
    guard let output = Nano.UnnestContents.process(input).success() else {
      Issue.record("UnnestContents failed")
      return
    }
    guard let output = Nano.MergeNeighbours.process(output).success() else {
      Issue.record("MergeNeighbours failed")
      return
    }

    do {
      let expressions = output[0].body
      #expect(expressions.count == 1)
      #expect(
        expressions[0].prettyPrint() == """
          text "ABCC"
          """)
    }

    do {
      let expressions = output[1].body
      #expect(expressions.count == 1)
      #expect(
        expressions[0].prettyPrint() == """
          text "BC"
          """)
    }

    do {
      let expressions = output[2].body
      #expect(expressions.count == 1)
      #expect(
        expressions[0].prettyPrint() == """
          text "C"
          """)
    }

    do {
      let expressions = output[3].body
      #expect(expressions.count == 1)
      #expect(
        expressions[0].prettyPrint() == """
          emph
          └ text "DE"
          """)
    }
  }

  @Test
  func mergeNeighbours() {
    let A = Template(
      name: "A", body: [ContentExpr([TextExpr("A")]), ContentExpr()],
      layoutType: .inline)
    let B = Template(
      name: "B", body: [ContentExpr(), ContentExpr([TextExpr("B")])],
      layoutType: .inline)
    let C = Template(
      name: "C", body: [ContentExpr([TextExpr("A")]), ContentExpr([TextExpr("B")])],
      layoutType: .inline)
    let D = Template(
      name: "D", body: [ContentExpr([LinebreakExpr()]), ContentExpr([LinebreakExpr()])],
      layoutType: .inline)

    let input = [A, B, C, D]
    guard let output = Nano.MergeNeighbours.process(input).success() else {
      Issue.record("MergeNeighbours failed")
      return
    }
    #expect(output.count == 4)

    #expect(
      prettyPrint(output[0]) == """
        content
        └ content
          └ text "A"
        """)
    #expect(
      prettyPrint(output[1]) == """
        content
        └ content
          └ text "B"
        """)
    #expect(
      prettyPrint(output[2]) == """
        content
        └ content
          └ text "AB"
        """)
    #expect(
      prettyPrint(output[3]) == """
        content
        └ content
          ├ linebreak
          └ linebreak
        """)
  }

  @Test
  func testConvertVariables() {
    let foo =
      Template(
        name: "foo",
        parameters: ["x", "y", "z"],
        body: [
          VariableExpr("z", .inline),
          TextExpr("="),
          VariableExpr("x", .inline),
          TextExpr("+"),
          VariableExpr("y", .inline),
        ],
        layoutType: .inline)

    let input = [foo]
    guard let output = Nano.ConvertVariables.process(input).success(),
      let output = output.getOnlyElement()
    else {
      Issue.record("ConvertVariables")
      return
    }

    let body = output.body

    #expect(
      ContentExpr(body).prettyPrint() == """
        content
        ├ cVariable #2 +0
        ├ text "="
        ├ cVariable #0 +0
        ├ text "+"
        └ cVariable #1 +0
        """)
  }

  @Test
  func testComputeNestedLevelDelta() {
    let foo =
      Template(
        name: "foo",
        parameters: ["x"],
        body: [
          FractionExpr(
            num: [CompiledVariableExpr(0, .inline)],
            denom: [
              FractionExpr(
                num: [CompiledVariableExpr(0, .inline)], denom: [TextExpr("2")])
            ])
        ],
        layoutType: .inline)

    let input = [foo]
    guard let output = Nano.ComputeNestedLevelDelta.process(input).success(),
      let output = output.getOnlyElement()
    else {
      Issue.record("ComputeNestedLevelDelta")
      return
    }

    let body = output.body

    #expect(
      ContentExpr(body).prettyPrint() == """
        content
        └ fraction frac
          ├ num
          │ └ cVariable #0 +1
          └ denom
            └ fraction frac
              ├ num
              │ └ cVariable #0 +2
              └ denom
                └ text "2"
        """)

  }

  @Test
  func testComputeLookupTables() {
    let templates = [square_idx, circle_idx, ellipse_idx, SOS_idx]

    let result = Nano.ComputeLookupTables.process(templates)

    guard let output = result.success() else {
      Issue.record("LocateNamelessVariables failed")
      return
    }

    #expect(output.count == 4)

    #expect(
      output[0].annotation == [
        0: [TreePath([.index(0), .mathIndex(.nuc), .index(0)])]
      ])
    #expect(
      output[1].annotation == [
        0: [TreePath([.index(0), .mathIndex(.nuc), .index(0)])],
        1: [TreePath([.index(2), .mathIndex(.nuc), .index(0)])],
      ])
    #expect(
      output[2].annotation == [
        0: [
          TreePath([
            .index(0),
            .mathIndex(.num),
            .index(0),
            .mathIndex(.nuc),
            .index(0),
          ])
        ],
        1: [
          TreePath([
            .index(2),
            .mathIndex(.num),
            .index(0),
            .mathIndex(.nuc),
            .index(0),
          ])
        ],
      ])
    #expect(
      output[3].annotation == [
        0: [
          TreePath([.index(0), .mathIndex(.nuc), .index(0)]),
          TreePath([.index(2), .mathIndex(.nuc), .index(0)]),
          TreePath([.index(4), .mathIndex(.nuc), .index(0)]),
        ]
      ])
  }

  @Test
  func coverage_ComputeLookupTables() {
    let t1 = Template(
      name: "t1",
      parameters: ["x", "y"],
      body: [
        LinebreakExpr(),
        UnknownExpr(.string("Hello")),
        TextStylesExpr(
          .emph, [TextExpr("World"), CompiledVariableExpr(0, .inline)]),
        HeadingExpr(
          .sectionAst, [TextExpr("Heading"), CompiledVariableExpr(1, .inline)]),
        ParagraphExpr([TextExpr("Paragraph"), CompiledVariableExpr(0, .inline)]),
        RootExpr([TextExpr("Root"), CompiledVariableExpr(1, .inline)]),
        TextStylesExpr(
          .textbf, [TextExpr("Strong"), CompiledVariableExpr(0, .inline)]),
        //
      ],
      layoutType: .inline)
    let t2 = Template(
      name: "t2",
      parameters: ["x"],
      body: [
        EquationExpr(
          .display,
          [
            AccentExpr(.dot, [CompiledVariableExpr(0, .inline)]),
            LeftRightExpr(.BRACE, [TextExpr("Brace")]),
            MathExpressionExpr(.bmod),
            MathOperatorExpr(.Pr),
            NamedSymbolExpr(.lookup("rightarrow")!),
            MatrixExpr(
              .Bmatrix,
              [
                MatrixExpr.Row([
                  ContentExpr([TextExpr("1")]),
                  ContentExpr([TextExpr("2")]),
                ]),
                MatrixExpr.Row([
                  ContentExpr([TextExpr("3")]),
                  ContentExpr([TextExpr("4")]),
                ]),
              ]),
            MultilineExpr(
              .multlineAst,
              [
                MultilineExpr.Row([
                  ContentExpr([TextExpr("a")])
                ]),
                MultilineExpr.Row([
                  ContentExpr([TextExpr("a")])
                ]),
              ]),
            RadicalExpr(
              [CompiledVariableExpr(0, .inline)], index: [TextExpr("n")]),
            TextModeExpr([TextExpr("Text Mode")]),
            UnderOverExpr(.overline, [TextExpr("Overline")]),
          ])
      ],
      layoutType: .inline)

    let templates = [t1, t2]
    let result = Nano.ComputeLookupTables.process(templates)
    #expect(result.isSuccess)
  }
}
