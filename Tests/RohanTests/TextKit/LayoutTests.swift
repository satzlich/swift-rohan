// Copyright 2024-2025 Lie Yan

import AppKit
import CoreGraphics
import Foundation
import Testing

@testable import Rohan

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
          [
            TextNode("f(n)+"),
            FractionNode([TextNode("g(n+1)")], [TextNode("h(n+2)")]),
          ]
        ),
        TextNode("where "),
        EquationNode(
          isBlock: false,
          [TextNode("n")]
        ),
        TextNode(" is a natural number."),
        EquationNode(
          isBlock: true,
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
    try documentManager.replaceContents(in: documentManager.documentRange, with: content)

    func outputPDF(_ functionaName: String, _ n: Int) {
      self.outputPDF(functionaName.dropLast(2) + "_\(n)", documentManager)
    }

    // output PDF
    outputPDF(#function, 1)

    // delete
    do {
      let path: [RohanIndex] = [.index(0)]
      let textRange = RhTextRange(TextLocation(path, 1), TextLocation(path, 2))!
      try documentManager.replaceContents(in: textRange, with: nil)
    }
    outputPDF(#function, 2)

    // insert
    do {
      let path: [RohanIndex] = [.index(0)]
      let textRange = RhTextRange(TextLocation(path, 0))
      try documentManager.replaceCharacters(in: textRange, with: "2025 ")
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
            [
              FractionNode([TextNode("m+n")], [TextNode("n")])
            ]
          ),
          TextNode(" Bravo"),
        ]),
      ParagraphNode([
        TextNode("The equation is "),
        EquationNode(
          isBlock: false,
          [
            TextNode("f(n)+"),
            FractionNode([TextNode("m+n")], [TextNode("n")], isBinomial: true),
            TextNode("+"),
            FractionNode([TextNode("m+n")], [TextNode("n")]), TextNode("-k."),
          ]
        ),
      ]),
    ]

    let documentManager = createDocumentManager(RootNode())
    try! documentManager.replaceContents(in: documentManager.documentRange, with: content)

    func outputPDF(_ functionaName: String, _ n: Int) {
      self.outputPDF(functionaName.dropLast(2) + "_\(n)", documentManager)
    }

    outputPDF(#function, 1)

    // replace
    do {
      let path: [RohanIndex] = [
        .index(0),
        .index(1),
        .mathIndex(.nucleus),
      ]
      let textRange = RhTextRange(TextLocation(path, 1))
      try documentManager.replaceCharacters(in: textRange, with: "-c>100")
    }
    outputPDF(#function, 2)

    // remove
    do {
      let path: [RohanIndex] = [
        .index(0),
        .index(1),
        .mathIndex(.nucleus),
      ]
      let textRange = RhTextRange(TextLocation(path, 0), TextLocation(path, 1))!
      try documentManager.replaceContents(in: textRange, with: nil)
    }
    outputPDF(#function, 3)
  }
}
