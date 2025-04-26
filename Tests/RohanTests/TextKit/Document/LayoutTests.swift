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
          isBlock: true,
          nuc: [
            TextNode("f(n)+"),
            FractionNode(
              num: [TextNode("g(n+1)")], denom: [TextNode("h(n+2)")]),
          ]
        ),
        TextNode("where "),
        EquationNode(
          isBlock: false,
          nuc: [TextNode("n")]
        ),
        TextNode(" is a natural number."),
        EquationNode(
          isBlock: true,
          nuc: [
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
      let path: [RohanIndex] = [.index(0)]
      let textRange = RhTextRange(TextLocation(path, 1), TextLocation(path, 2))!
      let result = documentManager.replaceContents(in: textRange, with: nil)
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[0↓,0↓]:6")
    }
    outputPDF(#function, 2)

    // insert
    do {
      let path: [RohanIndex] = [.index(0)]
      let textRange = RhTextRange(TextLocation(path, 0))
      let result = documentManager.replaceCharacters(in: textRange, with: "2025 ")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[0↓,0↓]:0")
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
            isBlock: false,
            nuc: [
              FractionNode(num: [TextNode("m+n")], denom: [TextNode("n")])
            ]
          ),
          TextNode(" Bravo"),
        ]),
      ParagraphNode([
        TextNode("The equation is "),
        EquationNode(
          isBlock: false,
          nuc: [
            TextNode("f(n)+"),
            FractionNode(
              num: [TextNode("m+n")], denom: [TextNode("n")], isBinomial: true
            ),
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
      let path: [RohanIndex] = [
        .index(0),
        .index(1),
        .mathIndex(.nuc),
      ]
      let textRange = RhTextRange(TextLocation(path, 1))
      let result = documentManager.replaceCharacters(in: textRange, with: "-c>100")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[0↓,1↓,nuc,1↓]:0")
    }
    outputPDF(#function, 2)

    // remove
    do {
      let path: [RohanIndex] = [
        .index(0),
        .index(1),
        .mathIndex(.nuc),
      ]
      let textRange = RhTextRange(TextLocation(path, 0), TextLocation(path, 1))!
      let result = documentManager.replaceContents(in: textRange, with: nil)
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[0↓,1↓,nuc,0↓]:0")
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
            isBlock: true,
            nuc: [
              AttachNode(
                nuc: [TextNode("Fe")], sub: [TextNode("3")], sup: [TextNode("2+")])
            ]
          ),
        ]),
      ParagraphNode([
        TextNode("reference text"),
        EquationNode(
          isBlock: true,
          nuc: [
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
          isBlock: true,
          nuc: [
            TextNode("t="),
            AttachNode(
              nuc: [TextNode("∑")], sub: [TextNode("a")], sup: [TextNode("b")]),
          ]
        )
      ]),
      ParagraphNode([
        EquationNode(
          isBlock: true,
          nuc: [
            TextNode("t="),
            AttachNode(
              nuc: [TextNode("\u{222B}")], sub: [TextNode("a")], sup: [TextNode("b")]),
          ]
        )
      ]),
      ParagraphNode([
        EquationNode(
          isBlock: true,
          nuc: [
            TextNode("t="),
            AttachNode(
              nuc: [TextNode("\u{220F}")], lsub: [TextNode("a")], lsup: [TextNode("b")]),
          ]
        )
      ]),
    ]

    let documentManager = createDocumentManager(RootNode(), StyleSheets.latinModern(12))
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(#function, documentManager)
  }

  @Test
  func testAccent() {
    let content = [
      ParagraphNode([
        EquationNode(
          isBlock: true,
          nuc: [
            TextNode("x"),
            AccentNode(accent: Characters.grave, nucleus: [TextNode("x")]),
            AccentNode(accent: Characters.breve, nucleus: [TextNode("x")]),
            AccentNode(accent: Characters.rightArrowAbove, nucleus: [TextNode("x")]),
            AccentNode(accent: Characters.rightArrowAbove, nucleus: [TextNode("abc")]),
            AccentNode(accent: Characters.bar, nucleus: [TextNode("p")]),
          ])
      ])
    ]
    let documentManager = createDocumentManager(RootNode(), StyleSheets.latinModern(12))
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
          isBlock: true,
          nuc: [
            TextNode("z="),
            MatrixNode(
              [
                MatrixNode.Row([
                  [TextNode("a")],
                  [TextNode("b")],
                ]),
                MatrixNode.Row([
                  [TextNode("-b")],
                  [TextNode("a")],
                ]),
              ], DelimiterPair.PAREN),
          ])
      ]),
      ParagraphNode([
        EquationNode(
          isBlock: true,
          nuc: [
            AttachNode(nuc: [TextNode("e")], sub: [TextNode("1")]),
            TextNode("="),
            MatrixNode(
              [
                MatrixNode.Row([
                  [TextNode("1")]
                ]),
                MatrixNode.Row([
                  [TextNode("0")]
                ]),
                MatrixNode.Row([
                  [TextNode("0")]
                ]),
              ], DelimiterPair.BRACKET),
          ])
      ]),
    ]

    let documentManager = createDocumentManager(RootNode(), StyleSheets.latinModern(12))
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
        EquationNode(isBlock: false, nuc: []),
        TextNode("."),
      ]),
      ParagraphNode([
        TextNode("Empty equation: "),
        EquationNode(
          isBlock: false,
          nuc: [
            FractionNode(num: [], denom: []),
            TextNode("+"),
            FractionNode(num: [], denom: [], isBinomial: true),
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
          isBlock: false,
          nuc: [
            ApplyNode(CompiledSamples.newtonsLaw, [])!,
            TextNode("."),
          ]),
        TextNode(" Here is another sample: "),
        ApplyNode(
          CompiledSamples.philipFox,
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
          isBlock: false,
          nuc: [
            ApplyNode(CompiledSamples.newtonsLaw, [])!,
            TextNode("."),
          ]),
        TextNode(" Here is another sample: "),
        ApplyNode(
          CompiledSamples.philipFox,
          [
            [TextNode("Philip")],
            [TextNode("Fox")],
          ])!,
      ]),
      ParagraphNode([
        TextNode("Sample of nested apply nodes: "),
        ApplyNode(
          CompiledSamples.doubleText,
          [
            [ApplyNode(CompiledSamples.doubleText, [[TextNode("fox")]])!]
          ])!,
      ]),
      HeadingNode(
        level: 1,
        [
          EquationNode(
            isBlock: false,
            nuc: [
              TextNode("m+"),
              ApplyNode(
                CompiledSamples.complexFraction, [[TextNode("x")], [TextNode("y")]])!,
              TextNode("+n"),
            ])
        ]),
      ParagraphNode([
        EquationNode(
          isBlock: true,
          nuc: [
            ApplyNode(
              CompiledSamples.bifun,
              [
                [ApplyNode(CompiledSamples.bifun, [[TextNode("n+1")]])!]
              ])!
          ])
      ]),
    ]

    let documentManager = createDocumentManager(RootNode())
    _ = documentManager.replaceContents(in: documentManager.documentRange, with: content)

    outputPDF(String(#function.dropLast(2)), documentManager)
  }
}
