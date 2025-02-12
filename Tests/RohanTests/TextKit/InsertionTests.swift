// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import Rohan

struct InsertionTests {
  @Test
  func testInsert() throws {
    // create content storage and layout manager
    let contentStorage = ContentStorage(
      RootNode([
        HeadingNode(
          level: 1,
          [
            EmphasisNode([TextNode("Newton's😀")])
          ]),
        ParagraphNode([
          EquationNode(
            isBlock: true,
            [
              TextNode("=m"),
              FractionNode([TextNode("d")], [TextNode("dt")]),
            ])
        ]),
      ])
    )
    let layoutManager = LayoutManager(StyleSheetTests.sampleStyleSheet())

    // set up text container
    let pageSize = CGSize(width: 250, height: 200)
    layoutManager.textContainer = NSTextContainer(
      size: CGSize(
        width: pageSize.width,
        height: 0))

    // set up layout manager
    contentStorage.setLayoutManager(layoutManager)

    // check document
    #expect(
      contentStorage.rootNode.prettyPrint() == """
        root
         ├ heading
         │  └ emphasis
         │     └ text "Newton's😀"
         └ paragraph
            └ equation
               └ nucleus
                  ├ text "=m"
                  └ fraction
                     ├ numerator
                     │  └ text "d"
                     └ denominator
                        └ text "dt"
        """)

    // function for outputting PDF
    func outputPDF(_ functionName: String, _ n: Int) throws {
      let fileName = String(functionName.dropLast(2) + "_\(n)")
      try TestUtils.outputPDF(
        folderName: folderName, fileName, CGSize(width: 270, height: 200), layoutManager)
      #expect(contentStorage.rootNode.isDirty == false)
    }

    try outputPDF(#function, 1)

    // do insertion in the middle of a text node
    do {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // emphasis
        .index(0),  // text "ewton's"
      ]
      let offset = "Newton's".count
      let range = RhTextRange(TextLocation(path, offset))

      try! contentStorage.replaceContents(in: range, with: " Second Law of Motion")
    }
    // check document
    #expect(
      contentStorage.rootNode.prettyPrint() == """
        root
         ├ heading
         │  └ emphasis
         │     └ text "Newton's Second Law of Motion😀"
         └ paragraph
            └ equation
               └ nucleus
                  ├ text "=m"
                  └ fraction
                     ├ numerator
                     │  └ text "d"
                     └ denominator
                        └ text "dt"
        """)
    // output PDF
    try outputPDF(#function, 2)

    // do insertion in the root
    do {
      let location = TextLocation([], 1)
      let range = RhTextRange(location)
      try! contentStorage.replaceContents(in: range, with: "states:")
    }
    do {
      let location = TextLocation([], 1)
      let range = RhTextRange(location)
      try! contentStorage.replaceContents(in: range, with: "The law of motion ")
    }
    do {
      let location = TextLocation([], 2)
      let range = RhTextRange(location)
      try! contentStorage.replaceContents(in: range, with: "Veni. Vidi. Vici.")
    }
    // check document
    #expect(
      contentStorage.rootNode.prettyPrint() == """
        root
         ├ heading
         │  └ emphasis
         │     └ text "Newton's Second Law of Motion😀"
         └ paragraph
            ├ text "The law of motion states:"
            ├ equation
            │  └ nucleus
            │     ├ text "=m"
            │     └ fraction
            │        ├ numerator
            │        │  └ text "d"
            │        └ denominator
            │           └ text "dt"
            └ text "Veni. Vidi. Vici."
        """)

    // output PDF
    try outputPDF(#function, 3)

    // do insertion in the equation
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
      ]
      let range = RhTextRange(TextLocation(path, 0))
      try! contentStorage.replaceContents(in: range, with: "F")
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(1),  // fraction
        .mathIndex(.numerator),  // numerator
      ]
      let range = RhTextRange(TextLocation(path, 1))
      try! contentStorage.replaceContents(in: range, with: "v")
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
      ]
      let range = RhTextRange(TextLocation(path, 2))
      try! contentStorage.replaceContents(in: range, with: ".")
    }

    // check document
    #expect(
      contentStorage.rootNode.prettyPrint() == """
        root
         ├ heading
         │  └ emphasis
         │     └ text "Newton's Second Law of Motion😀"
         └ paragraph
            ├ text "The law of motion states:"
            ├ equation
            │  └ nucleus
            │     ├ text "F=m"
            │     ├ fraction
            │     │  ├ numerator
            │     │  │  └ text "dv"
            │     │  └ denominator
            │     │     └ text "dt"
            │     └ text "."
            └ text "Veni. Vidi. Vici."
        """)

    // output PDF
    try outputPDF(#function, 4)
  }

  private let folderName: String
  init() throws {
    self.folderName = String("\(type(of: self))")
    try TestUtils.touchDirectory(folderName)
  }
}
