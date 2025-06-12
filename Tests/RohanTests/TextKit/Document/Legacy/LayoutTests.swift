// Copyright 2024-2025 Lie Yan

import AppKit
import CoreGraphics
import Foundation
import Testing

@testable import SwiftRohan

final class LayoutTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: true)
  }

  @Test
  func testLayout() throws {
    // insert content
    let content = [
      HeadingNode(
        level: 1,
        [
          TextNode("Alpha "),
          EmphasisNode([TextNode("Bravo Charlie")]),
        ]),
      ParagraphNode([
        TextNode("The quick brown fox "),
        EmphasisNode([
          TextNode("jumps over the "),
          EmphasisNode([TextNode("lazy ")]),
          TextNode("dog."),
        ]),
      ]),
      ParagraphNode([
        TextNode("😀 The equation is "),
        EquationNode(
          .block,
          [
            TextNode("f(n)+"),
            FractionNode(
              num: [TextNode("g(n+1)")], denom: [TextNode("h(n+2)")]),
          ]
        ),
        TextNode("where "),
        EquationNode(.inline, [TextNode("n")]),
        TextNode(" is a natural number."),
        EquationNode(
          .block,
          [
            TextNode("f(n+2)=f(n+1)+f(n)")
          ]
        ),
      ]),
      ParagraphNode([
        TextNode("May the force be with you!")
      ]),
    ]

    let documentManager = createDocumentManager(RootNode())
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    func outputPDF(_ functionaName: String, _ n: Int) {
      self.outputPDF(functionaName.dropLast(2) + "_\(n)", documentManager)
    }

    // output PDF
    outputPDF(#function, 1)

    // delete
    do {
      let textRange = RhTextRange.parse("[↓0]:1..<[↓0]:2")!
      let result = documentManager.replaceContents(in: textRange, with: nil)
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[↓0,↓0]:6")
    }
    outputPDF(#function, 2)

    // insert
    do {
      let textRange = RhTextRange.parse("[↓0]:0")!
      let result = documentManager.replaceCharacters(in: textRange, with: "2025 ")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[↓0,↓0]:0")
    }
    outputPDF(#function, 3)
  }

  @Test
  func testFraction() throws {
    // set up content
    let content = [
      HeadingNode(
        level: 1,
        [
          TextNode("Alpha "),
          EquationNode(
            .inline,
            [
              FractionNode(num: [TextNode("m+n")], denom: [TextNode("n")])
            ]
          ),
          TextNode(" Bravo"),
        ]),
      ParagraphNode([
        TextNode("The equation is "),
        EquationNode(
          .inline,
          [
            TextNode("f(n)+"),
            FractionNode(
              num: [TextNode("m+n")], denom: [TextNode("n")], genfrac: .binom),
            TextNode("+"),
            FractionNode(num: [TextNode("m+n")], denom: [TextNode("n")]),
            TextNode("-k."),
          ]
        ),
      ]),
    ]

    let documentManager = createDocumentManager(RootNode())
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    func outputPDF(_ functionaName: String, _ n: Int) {
      self.outputPDF(functionaName.dropLast(2) + "_\(n)", documentManager)
    }

    outputPDF(#function, 1)

    // replace
    do {
      let textRange = RhTextRange.parse("[↓0,↓1,nuc]:1")!
      let result = documentManager.replaceCharacters(in: textRange, with: "-c>100")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[↓0,↓1,nuc,↓1]:0")
    }
    outputPDF(#function, 2)

    // remove
    do {
      let textRange = RhTextRange.parse("[↓0,↓1,nuc]:0..<[↓0,↓1,nuc]:1")!
      let result = documentManager.replaceContents(in: textRange, with: nil)
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[↓0,↓1,nuc,↓0]:0")
    }
    outputPDF(#function, 3)
  }

  @Test
  func testAttach() throws {
    // set up content
    let content = [
      ParagraphNode(
        [
          TextNode("reference text"),
          EquationNode(
            .block,
            [
              AttachNode(
                nuc: [TextNode("Fe")], sub: [TextNode("3")], sup: [TextNode("2+")])
            ]
          ),
        ]),
      ParagraphNode([
        TextNode("reference text"),
        EquationNode(
          .block,
          [
            TextNode("F=G"),
            FractionNode(
              num: [TextNode("Mm")],
              denom: [AttachNode(nuc: [TextNode("r")], sup: [TextNode("2")])],
            ),
          ]
        ),
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("t="),
            AttachNode(
              nuc: [TextNode("∑")], sub: [TextNode("a")], sup: [TextNode("b")]),
          ]
        )
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("t="),
            AttachNode(
              nuc: [TextNode("\u{222B}")], sub: [TextNode("a")], sup: [TextNode("b")]),
          ]
        )
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("t="),
            AttachNode(
              nuc: [TextNode("\u{220F}")], lsub: [TextNode("a")], lsup: [TextNode("b")]),
          ]
        )
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("t="),
            AttachNode(nuc: [TextNode("f")], sup: [TextNode("\u{2032}")]),
          ]
        )
      ]),
    ]

    let documentManager = createDocumentManager(
      RootNode(), StyleSheets.testingRecord.provider(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testAccent() {
    let content = [
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("x"),
            AccentNode(MathAccent.grave, nucleus: [TextNode("x")]),
            AccentNode(MathAccent.breve, nucleus: [TextNode("x")]),
            AccentNode(MathAccent.vec, nucleus: [TextNode("x")]),
            AccentNode(MathAccent.vec, nucleus: [TextNode("abc")]),
            AccentNode(MathAccent.bar, nucleus: [TextNode("p")]),
          ])
      ])
    ]
    let documentManager = createDocumentManager(
      RootNode(), StyleSheets.testingRecord.provider(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testMatrix() {
    let content: [Node] = [
      ParagraphNode([
        TextNode("The quick brown fox jumps over the lazy dog.")
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("z="),
            MatrixNode(
              .pmatrix,
              [
                MatrixNode.Row([
                  MatrixNode.Cell([TextNode("a")]),
                  MatrixNode.Cell([TextNode("b")]),
                ]),
                MatrixNode.Row([
                  MatrixNode.Cell([TextNode("-b")]),
                  MatrixNode.Cell([TextNode("a")]),
                ]),
              ]),
          ])
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            AttachNode(nuc: [TextNode("e")], sub: [TextNode("1")]),
            TextNode("="),
            MatrixNode(
              .bmatrix,
              [
                MatrixNode.Row([
                  MatrixNode.Cell([TextNode("1")])
                ]),
                MatrixNode.Row([
                  MatrixNode.Cell([TextNode("0")])
                ]),
                MatrixNode.Row([
                  MatrixNode.Cell([TextNode("0")])
                ]),
              ]),
          ])
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("z="),
            MatrixNode(
              .aligned,
              [
                MatrixNode.Row([
                  MatrixNode.Cell([TextNode("a")]),
                  MatrixNode.Cell([TextNode("b")]),
                ]),
                MatrixNode.Row([
                  MatrixNode.Cell([TextNode("-b")]),
                  MatrixNode.Cell([TextNode("a")]),
                ]),
              ]),
          ])
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("z="),
            MatrixNode(
              .cases,
              [
                MatrixNode.Row([
                  MatrixNode.Cell([TextNode("a")]),
                  MatrixNode.Cell([TextNode("b")]),
                ]),
                MatrixNode.Row([
                  MatrixNode.Cell([TextNode("-b")]),
                  MatrixNode.Cell([TextNode("a")]),
                ]),
              ]),
          ])
      ]),
    ]

    let documentManager = createDocumentManager(
      RootNode(), StyleSheets.testingRecord.provider(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testLeftRight() {
    let content: [Node] = [
      ParagraphNode([
        TextNode("The quick brown fox jumps over the lazy dog.")
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("z="),
            LeftRightNode(
              DelimiterPair.PAREN,
              [
                FractionNode(num: [TextNode("F")], denom: [TextNode("m")])
              ]),
          ])
      ]),
    ]

    let documentManager = createDocumentManager(
      RootNode(), StyleSheets.testingRecord.provider(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testUnderOverspreader() {
    let content: [Node] = [
      ParagraphNode([
        TextNode("The quick brown fox jumps over the lazy dog.")
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("z="),
            UnderOverNode(MathSpreader.overbrace, [TextNode("ab")]),
            TextNode("+"),
            UnderOverNode(MathSpreader.underbrace, [TextNode("xyz")]),
            TextNode("+"),
            UnderOverNode(MathSpreader.overbracket, [TextNode("ab")]),
            TextNode("+"),
            UnderOverNode(MathSpreader.underbracket, [TextNode("xyz")]),
            TextNode("+"),
            UnderOverNode(MathSpreader.overparen, [TextNode("ab")]),
            TextNode("+"),
            UnderOverNode(MathSpreader.underparen, [TextNode("xyz")]),
            TextNode("+"),
            UnderOverNode(MathSpreader.xleftarrow, [TextNode("xyz")]),
          ])
      ]),
    ]

    let documentManager = createDocumentManager(
      RootNode(), StyleSheets.testingRecord.provider(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testRoot() {
    let content: [Node] = [
      ParagraphNode([
        TextNode("The quick brown fox jumps over the lazy dog.")
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("z="),
            RadicalNode([TextNode("n+1")]),
            TextNode("+"),
            RadicalNode([TextNode("n+1")], index: [TextNode("2")]),
          ])
      ]),
    ]

    let documentManager = createDocumentManager(
      RootNode(), StyleSheets.testingRecord.provider(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testMathKind() {
    let content: [Node] = [
      ParagraphNode([
        TextNode("The quick brown fox jumps over the lazy dog.")
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("f"),
            MathAttributesNode(.mathpunct, [TextNode(":")]),
            TextNode("X"),
            NamedSymbolNode(NamedSymbol.lookup("rightarrow")!),
            TextNode("Y"),
          ])
      ]),
    ]
    let documentManager = createDocumentManager(
      RootNode(), StyleSheets.testingRecord.provider(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testMathOperator() {
    let content: [Node] = [
      ParagraphNode([
        TextNode("The quick brown fox jumps over the lazy dog.")
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("z="),
            AttachNode(
              nuc: [MathOperatorNode(MathOperator.min)],
              sub: [TextNode("x>0")]),
          ]
        )
      ]),
    ]

    let documentManager = createDocumentManager(
      RootNode(), StyleSheets.testingRecord.provider(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testMathVariant() {
    let content: [Node] = [
      ParagraphNode([
        TextNode("The quick brown fox jumps over the lazy dog.")
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("z="),
            MathStylesNode(.mathbb, [TextNode("Bb")]),
            MathStylesNode(.mathcal, [TextNode("Cal")]),
            MathStylesNode(.mathfrak, [TextNode("Frak")]),
            MathStylesNode(.mathtt, [TextNode("mono")]),
            MathStylesNode(.mathsf, [TextNode("sans")]),
            MathStylesNode(.mathrm, [TextNode("serif")]),
          ])
      ]),
    ]

    let documentManager = createDocumentManager(
      RootNode(), StyleSheets.testingRecord.provider(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testTextMode() {
    let content: [Node] = [
      ParagraphNode([
        TextNode("The quick brown fox jumps over the lazy dog.")
      ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            TextNode("f(n)"),
            TextModeNode([
              TextNode(" where ")
            ]),
            TextNode("n>0"),
          ]
        )
      ]),
    ]

    let documentManager = createDocumentManager(
      RootNode(), StyleSheets.testingRecord.provider(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testEmptyElement() throws {
    let content = [
      HeadingNode(level: 1, [TextNode("H1")]),
      HeadingNode(level: 2, []),
      HeadingNode(level: 3, [TextNode("H3")]),
      HeadingNode(level: 4, [TextNode("H4"), EmphasisNode([])]),
      HeadingNode(level: 5, [TextNode("H5")]),
      ParagraphNode([
        TextNode("Empty equation: "),
        EquationNode(.inline, []),
        TextNode("."),
      ]),
      ParagraphNode([
        TextNode("Empty equation: "),
        EquationNode(
          .inline,
          [
            FractionNode(num: [], denom: []),
            TextNode("+"),
            FractionNode(num: [], denom: [], genfrac: .binom),
          ]),
        TextNode("."),
      ]),
    ]
    let documentManager = createDocumentManager(RootNode())
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(String(#function.dropLast(2)), documentManager)
  }

  @Test
  func regress_PlaceholderBug() throws {
    // set up content
    let content: [Node] = [
      ParagraphNode([
        TextNode("Newton's second law of motion: "),
        EquationNode(
          .inline,
          [
            ApplyNode(MathTemplateSamples.newtonsLaw, [])!,
            TextNode("."),
          ]),
        TextNode(" Here is another sample: "),
        ApplyNode(
          MathTemplateSamples.philipFox,
          [
            [TextNode("Philip")],
            [TextNode("Fox")],
          ])!,
      ])
    ]

    let documentManager = createDocumentManager(RootNode())
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(String(#function.dropLast(2)), documentManager)
  }

  @Test
  func testApply() throws {
    // set up content
    let content: [Node] = [
      ParagraphNode([
        TextNode("Newton's second law of motion: "),
        EquationNode(
          .inline,
          [
            ApplyNode(MathTemplateSamples.newtonsLaw, [])!,
            TextNode("."),
          ]),
        TextNode(" Here is another sample: "),
        ApplyNode(
          MathTemplateSamples.philipFox,
          [
            [TextNode("Philip")],
            [TextNode("Fox")],
          ])!,
      ]),
      ParagraphNode([
        TextNode("Sample of nested apply nodes: "),
        ApplyNode(
          MathTemplateSamples.doubleText,
          [
            [ApplyNode(MathTemplateSamples.doubleText, [[TextNode("fox")]])!]
          ])!,
      ]),
      HeadingNode(
        level: 1,
        [
          EquationNode(
            .inline,
            [
              TextNode("m+"),
              ApplyNode(
                MathTemplateSamples.complexFraction, [[TextNode("x")], [TextNode("y")]])!,
              TextNode("+n"),
            ])
        ]),
      ParagraphNode([
        EquationNode(
          .block,
          [
            ApplyNode(
              MathTemplateSamples.bifun,
              [
                [ApplyNode(MathTemplateSamples.bifun, [[TextNode("n+1")]])!]
              ])!
          ])
      ]),
    ]

    let documentManager = createDocumentManager(RootNode())
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(String(#function.dropLast(2)), documentManager)
  }
}
