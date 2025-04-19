// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct SelectionRangeTests {
  @Test
  static func test_validateInsertionPoint() {
    let rootNode = RootNode([
      HeadingNode(
        level: 1,
        [
          EmphasisNode([TextNode("Fibonacci")]),
          TextNode(" Sequence"),
        ]),
      ParagraphNode([
        TextNode("Fibonacci sequence is defined as follows:"),
        EquationNode(isBlock: true, nucleus: [TextNode("f(n+2)=f(n+1)+f(n),")]),
        TextNode("where "),
        EquationNode(isBlock: false, nucleus: [TextNode("n")]),
        TextNode(" is a positive integer."),
      ]),
    ])

    // Convenience function
    func validate(_ location: TextLocation) -> Bool {
      Trace.from(location, rootNode) != nil
    }

    do {
      // text
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // emphasis
        .index(0),  // text
      ]
      #expect(validate(TextLocation(path, 1)))
      #expect(validate(TextLocation(path, "Fibonacci".count)))
      #expect(validate(TextLocation(path, "Fibonacci".count + 1)) == false)
    }
    do {
      // element
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
      ]
      #expect(validate(TextLocation(path, 0)))
      #expect(validate(TextLocation(path, 1)))
      #expect(validate(TextLocation(path, 2)) == false)
    }
    do {
      // invalid path
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // equation
      ]
      #expect(validate(TextLocation(path, 0)) == false)
      #expect(validate(TextLocation(path, 1)) == false)
    }
  }

  @Test
  static func test_validateSelectionRange_repairSelectionRange() {
    let rootNode = RootNode([
      HeadingNode(
        level: 1,
        [
          EmphasisNode([TextNode("Fibonacci")]),
          TextNode(" Sequence"),
        ]),
      ParagraphNode([
        TextNode("Fibonacci sequence is defined as follows:"),
        EquationNode(isBlock: true, nucleus: [TextNode("f(n+2)=f(n+1)+f(n),")]),
        TextNode("where "),
        EquationNode(isBlock: false, nucleus: [TextNode("n")]),
        TextNode(" is a positive integer."),
      ]),
    ])

    // Convenience function
    func validate(_ location: TextLocation, _ end: TextLocation) -> Bool {
      guard let range = RhTextRange(location, end)
      else { return false }
      return TreeUtils.validateRange(range, rootNode)
    }
    func repair(_ range: RhTextRange) -> RepairResult<RhTextRange> {
      return TreeUtils.repairRange(range, rootNode)
    }
    func repair(
      _ location: TextLocation, _ end: TextLocation
    ) -> RepairResult<RhTextRange> {
      guard let range = RhTextRange(location, end)
      else { return .failure }
      return TreeUtils.repairRange(range, rootNode)
    }

    // Case a)
    do {
      // text
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // emphasis
        .index(0),  // text
      ]

      // validate
      #expect(validate(TextLocation(path, 1), TextLocation(path, 3)))
      #expect(validate(TextLocation(path, 1), TextLocation(path, "Fibonacci".count)))
      #expect(
        validate(TextLocation(path, 1), TextLocation(path, "Fibonacci".count + 1))
          == false)

      // repair
      do {
        let range = RhTextRange(TextLocation(path, 1), TextLocation(path, 3))!
        #expect(repair(range) == .original(range))
      }

      do {
        let range = RhTextRange(
          TextLocation(path, 1), TextLocation(path, "Fibonacci".count))!
        #expect(repair(range) == .original(range))
      }

      do {
        let range = RhTextRange(
          TextLocation(path, 1), TextLocation(path, "Fibonacci".count + 1))!
        #expect(repair(range) == .failure)
      }
    }
    // Case b)
    do {
      let location = {
        let path: [RohanIndex] = [
          .index(0),  // heading
          .index(2),  // text
        ]
        return TextLocation(path, 1)
      }()
      let end = {
        let path: [RohanIndex] = [
          .index(1),  // paragraph
          .index(4),  // text
        ]
        return TextLocation(path, 3)
      }()

      // validate
      #expect(validate(location, end) == false)

      // repair
      #expect(repair(location, end) == .failure)
    }
    // Case c)
    do {
      let location = TextLocation([], 0)  // heading
      let end = {
        let path: [RohanIndex] = [
          .index(1),  // paragraph
          .index(4),  // text
        ]
        return TextLocation(path, 3)
      }()

      // validate
      #expect(validate(location, end))

      // repair
      let range = RhTextRange(location, end)!
      #expect(repair(range) == .original(range))
    }
    // Case d)
    do {
      let location = {
        let path: [RohanIndex] = [
          .index(1),  // paragraph
          .index(2),  // text
        ]
        return TextLocation(path, 1)
      }()
      let end = {
        let path: [RohanIndex] = [
          .index(1),  // paragraph
          .index(4),  // text
        ]
        return TextLocation(path, 3)
      }()
      // validate
      #expect(validate(location, end))
      // repair
      let range = RhTextRange(location, end)!
      #expect(repair(range) == .original(range))
    }
    // Case e)
    do {
      let location = {
        let path: [RohanIndex] = [
          .index(1),  // paragraph
          .index(1),  // equation
          .mathIndex(.nucleus),  // nucleus
          .index(0),  // text
        ]
        return TextLocation(path, 1)
      }()
      let end = {
        let path: [RohanIndex] = [
          .index(1),  // paragraph
          .index(3),  // equation
          .mathIndex(.nucleus),  // nucleus
          .index(0),  // text
        ]
        return TextLocation(path, 1)
      }()

      // validate
      #expect(validate(location, end) == false)

      // repair
      let fixedLocation = {
        let path: [RohanIndex] = [
          .index(1)  // paragraph
        ]
        return TextLocation(path, 1)
      }()
      let fixedEnd = {
        let path: [RohanIndex] = [
          .index(1)  // paragraph
        ]
        return TextLocation(path, 4)
      }()
      #expect(repair(location, end) == .repaired(RhTextRange(fixedLocation, fixedEnd)!))
    }
    // Case f)
    do {
      let location = {
        let path: [RohanIndex] = [
          .index(1),  // paragraph
          .index(1),  // equation
          .mathIndex(.nucleus),  // nucleus
          .index(0),  // text
        ]
        return TextLocation(path, 2)
      }()
      let end = {
        let path: [RohanIndex] = [
          .index(1),  // paragraph
          .index(4),  // text
        ]
        return TextLocation(path, 3)
      }()
      // validate
      #expect(validate(location, end) == false)
      // repair
      let fixedLocation = {
        let path: [RohanIndex] = [
          .index(1)  // paragraph
        ]
        return TextLocation(path, 1)
      }()
      #expect(repair(location, end) == .repaired(RhTextRange(fixedLocation, end)!))
    }
  }

  @Test
  static func test_repairRange_FractionNode() {
    let rootNode = RootNode([
      ParagraphNode([
        EquationNode(
          isBlock: false, nucleus: [FractionNode(numerator: [], denominator: [])])
      ])
    ])

    let path: [RohanIndex] = [
      .index(0),  // paragraph
      .index(0),  // equation
      .mathIndex(.nucleus),  // nucleus
      .index(0),  // fraction
      .mathIndex(.numerator),  // numerator
    ]
    let location = TextLocation(path, 0)

    let endPath: [RohanIndex] = [
      .index(0),  // paragraph
      .index(0),  // equation
      .mathIndex(.nucleus),  // nucleus
      .index(0),  // fraction
      .mathIndex(.denominator),  // denominator
    ]
    let endLocation = TextLocation(endPath, 0)

    let range = RhTextRange(location, endLocation)!
    #expect(TreeUtils.validateRange(range, rootNode) == false)

    let result = TreeUtils.repairRange(range, rootNode)
    let repairedRange = result.unwrap()!

    #expect("\(repairedRange)" == "[0↓,0↓,nucleus]:0..<[0↓,0↓,nucleus]:1")
  }

  @Test
  static func test_repairRange_EmphasisNode() {
    let rootNode = RootNode([
      ParagraphNode([
        TextNode("The quick brown "),
        EmphasisNode([TextNode("fox ")]),
        TextNode("jumps over the lazy dog."),
      ])
    ])

    do {
      let path: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let location = TextLocation(path, 0)

      let endPath: [RohanIndex] = [
        .index(0),  // paragraph
        .index(1),  // emphasis
        .index(0),  // text
      ]
      let endLocation = TextLocation(endPath, "fo".length)

      let range = RhTextRange(location, endLocation)!
      #expect(TreeUtils.validateRange(range, rootNode) == false)
      let result = TreeUtils.repairRange(range, rootNode)
      let repairedRange = result.unwrap()!
      #expect("\(repairedRange)" == "[0↓]:0..<[0↓]:2")
    }

    do {
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(1),  // emphasis
        .index(0),  // text
      ]
      let location = TextLocation(path, "fo".length)

      let endPath: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let endLocation = TextLocation(endPath, 3)

      let range = RhTextRange(location, endLocation)!
      #expect(TreeUtils.validateRange(range, rootNode) == false)
      let result = TreeUtils.repairRange(range, rootNode)
      let repairedRange = result.unwrap()!
      #expect("\(repairedRange)" == "[0↓]:1..<[0↓]:3")
    }
  }
}
