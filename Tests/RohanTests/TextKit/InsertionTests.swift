// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import Rohan

final class InsertionTests: TextKitTestsBase {
  @Test
  func testInsert() throws {
    let rootNode = RootNode([
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

    let documentManager = createDocumentManager(rootNode)

    // check document
    #expect(
      documentManager.prettyPrint() == """
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

    func outputPDF(_ functionaName: String, _ n: Int) {
      try self.outputPDF(functionaName.dropLast(2) + "_\(n)", documentManager)
    }

    outputPDF(#function, 1)

    // do insertion in the middle of a text node
    do {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // emphasis
        .index(0),  // text "Newton's"
      ]
      let offset = "Newton's".count
      let range = RhTextRange(TextLocation(path, offset))

      try documentManager.replaceContents(in: range, with: " Second Law of Motion")
    }
    // check document
    #expect(
      documentManager.prettyPrint() == """
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
    outputPDF(#function, 2)

    // do insertion in the root
    do {
      let location = TextLocation([], 1)
      let range = RhTextRange(location)
      try! documentManager.replaceContents(in: range, with: "states:")
    }
    do {
      let location = TextLocation([], 1)
      let range = RhTextRange(location)
      try! documentManager.replaceContents(in: range, with: "The law of motion ")
    }
    do {
      let location = TextLocation([], 2)
      let range = RhTextRange(location)
      try! documentManager.replaceContents(in: range, with: "Veni. Vidi. Vici.")
    }
    // check document
    #expect(
      documentManager.prettyPrint() == """
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
    outputPDF(#function, 3)

    // do insertion in the equation
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
      ]
      let range = RhTextRange(TextLocation(path, 0))
      try! documentManager.replaceContents(in: range, with: "F")
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
      try! documentManager.replaceContents(in: range, with: "v")
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
      ]
      let range = RhTextRange(TextLocation(path, 2))
      try! documentManager.replaceContents(in: range, with: ".")
    }

    // check document
    #expect(
      documentManager.prettyPrint() == """
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
    outputPDF(#function, 4)
  }
}
