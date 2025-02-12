// Copyright 2024-2025 Lie Yan

import AppKit
import CoreGraphics
import Foundation
import Testing

@testable import Rohan

struct LayoutTests {
  @Test
  func testLayout() throws {
    let contentStorage = ContentStorage()
    let layoutManager = LayoutManager(StyleSheetTests.sampleStyleSheet())

    // set up text container
    layoutManager.textContainer = NSTextContainer(size: CGSize(width: 200, height: 0))

    // set up layout manager
    contentStorage.setLayoutManager(layoutManager)
    #expect(contentStorage.layoutManager === layoutManager)
    #expect(layoutManager.contentStorage === contentStorage)

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

    try contentStorage.replaceContents(in: contentStorage.documentRange, with: content)

    // output PDF
    try outputPDF(#function.dropLast(2) + "_1", layoutManager)
    #expect(contentStorage.rootNode.isDirty == false)

    // delete
    do {
      let path: [RohanIndex] = [
        .index(0)
      ]
      let textRange = RhTextRange(TextLocation(path, 1), TextLocation(path, 2))!
      try contentStorage.replaceContents(in: textRange, with: nil)
    }
    #expect(contentStorage.rootNode.isDirty == true)
    try outputPDF(#function.dropLast(2) + "_2", layoutManager)
    #expect(contentStorage.rootNode.isDirty == false)

    // insert
    do {
      let path: [RohanIndex] = [
        .index(0)
      ]
      let textRange = RhTextRange(TextLocation(path, 0))
      try contentStorage.replaceContents(in: textRange, with: "2025 ")
    }
    #expect(contentStorage.rootNode.isDirty == true)
    try outputPDF(#function.dropLast(2) + "_3", layoutManager)
    #expect(contentStorage.rootNode.isDirty == false)
  }

  @Test
  func testFraction() throws {
    let contentStorage = ContentStorage()
    let layoutManager = LayoutManager(StyleSheetTests.sampleStyleSheet())

    // set up text container
    let pageSize = CGSize(width: 250, height: 200)
    layoutManager.textContainer = NSTextContainer(size: CGSize(width: pageSize.width, height: 0))

    // set up layout manager
    contentStorage.setLayoutManager(layoutManager)

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
    try! contentStorage.replaceContents(in: contentStorage.documentRange, with: content)

    try outputPDF(#function.dropLast(2) + "_1", layoutManager)
    #expect(contentStorage.rootNode.isDirty == false)

    // replace
    do {
      let path: [RohanIndex] = [
        .index(0),
        .index(1),
        .mathIndex(.nucleus),
      ]
      let textRange = RhTextRange(TextLocation(path, 1))
      try contentStorage.replaceContents(in: textRange, with: "-c>100")
    }
    #expect(contentStorage.rootNode.isDirty == true)
    try outputPDF(#function.dropLast(2) + "_2", layoutManager)
    #expect(contentStorage.rootNode.isDirty == false)

    // remove
    do {
      let path: [RohanIndex] = [
        .index(0),
        .index(1),
        .mathIndex(.nucleus),
      ]
      let textRange = RhTextRange(TextLocation(path, 0), TextLocation(path, 1))!
      try contentStorage.replaceContents(in: textRange, with: nil)
    }
    #expect(contentStorage.rootNode.isDirty == true)
    try outputPDF(#function.dropLast(2) + "_3", layoutManager)
    #expect(contentStorage.rootNode.isDirty == false)
  }

  private let folderName: String
  init() throws {
    self.folderName = String("\(type(of: self))")
    try TestUtils.touchDirectory(folderName)
  }

  private func outputPDF(_ fileName: String, _ layoutManager: LayoutManager) throws {
    try TestUtils.outputPDF(
      folderName: folderName, fileName, CGSize(width: 270, height: 200), layoutManager)
  }
}
