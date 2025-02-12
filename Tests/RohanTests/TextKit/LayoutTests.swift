// Copyright 2024-2025 Lie Yan

import AppKit
import CoreGraphics
import Foundation
import Testing

@testable import Rohan

struct LayoutTests {
  @Test
  func testLayout() throws {
    let documentManager = DocumentManager(StyleSheetTests.sampleStyleSheet(), RootNode())
    documentManager.textContainer = NSTextContainer(size: CGSize(width: 200, height: 0))

    // insert content
    let content = [
      HeadingNode(
        level: 1,
        [
          TextNode("Alpha "),
          EmphasisNode([
            TextNode("Bravo Charlie")
          ]),
        ]),
      ParagraphNode([
        TextNode("The quick brown fox "),
        EmphasisNode([
          TextNode("jumps over the "),
          EmphasisNode([
            TextNode("lazy ")
          ]),
          TextNode("dog."),
        ]),
      ]),
      ParagraphNode([
        TextNode("😀 The equation is "),
        EquationNode(
          isBlock: true,
          [
            TextNode("f(n)+"),
            FractionNode(
              [TextNode("g(n+1)")],
              [TextNode("h(n+2)")]),
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

    try documentManager.replaceContents(in: documentManager.documentRange, with: content)

    // output PDF
    try outputPDF(#function.dropLast(2) + "_1", documentManager)
    #expect(documentManager.isDirty == false)

    // delete
    do {
      let path: [RohanIndex] = [
        .index(0)
      ]
      let textRange = RhTextRange(TextLocation(path, 1), TextLocation(path, 2))!
      try documentManager.replaceContents(in: textRange, with: nil)
    }
    #expect(documentManager.isDirty == true)
    try outputPDF(#function.dropLast(2) + "_2", documentManager)
    #expect(documentManager.isDirty == false)

    // insert
    do {
      let path: [RohanIndex] = [
        .index(0)
      ]
      let textRange = RhTextRange(TextLocation(path, 0))
      try documentManager.replaceContents(in: textRange, with: "2025 ")
    }
    #expect(documentManager.isDirty == true)
    try outputPDF(#function.dropLast(2) + "_3", documentManager)
    #expect(documentManager.isDirty == false)
  }

  @Test
  func testFraction() throws {
    let documentManager = DocumentManager(StyleSheetTests.sampleStyleSheet(), RootNode())
    // set up text container
    documentManager.textContainer = NSTextContainer(size: CGSize(width: 250, height: 0))

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
          TextNode(" Bravo")
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
    try! documentManager.replaceContents(in: documentManager.documentRange, with: content)

    try outputPDF(#function.dropLast(2) + "_1", documentManager)
    #expect(documentManager.isDirty == false)

    // replace
    do {
      let path: [RohanIndex] = [
        .index(0),
        .index(1),
        .mathIndex(.nucleus),
      ]
      let textRange = RhTextRange(TextLocation(path, 1))
      try documentManager.replaceContents(in: textRange, with: "-c>100")
    }
    #expect(documentManager.isDirty == true)
    try outputPDF(#function.dropLast(2) + "_2", documentManager)
    #expect(documentManager.isDirty == false)

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
    #expect(documentManager.isDirty == true)
    try outputPDF(#function.dropLast(2) + "_3", documentManager)
    #expect(documentManager.isDirty == false)
  }

  private let folderName: String
  init() throws {
    self.folderName = String("\(type(of: self))")
    try TestUtils.touchDirectory(folderName)
  }

  private func outputPDF(_ fileName: String, _ documentManager: DocumentManager) throws {
    try TestUtils.outputPDF(
      folderName: folderName, fileName, CGSize(width: 270, height: 200), documentManager)
  }
}
