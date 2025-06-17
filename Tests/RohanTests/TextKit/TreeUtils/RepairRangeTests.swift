// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct RepairRangeTests {
  @Test
  static func test_validateInsertionPoint() {
    let rootNode = RootNode([
      HeadingNode(
        level: 1,
        [
          TextStylesNode(.emph, [TextNode("Fibonacci")]),
          TextNode(" Sequence"),
        ]),
      ParagraphNode([
        TextNode("Fibonacci sequence is defined as follows:"),
        EquationNode(.block, [TextNode("f(n+2)=f(n+1)+f(n),")]),
        TextNode("where "),
        EquationNode(.inline, [TextNode("n")]),
        TextNode(" is a positive integer."),
      ]),
    ])

    // Convenience function
    func validate(_ location: TextLocation) -> Bool {
      Trace.from(location, rootNode) != nil
    }

    do {
      // heading -> emphasis -> text
      let path: Array<RohanIndex> = TextLocation.parseIndices("[↓0,↓0,↓0]")!
      #expect(validate(TextLocation(path, 1)))
      #expect(validate(TextLocation(path, "Fibonacci".count)))
      #expect(validate(TextLocation(path, "Fibonacci".count + 1)) == false)
    }
    do {
      // paragraph -> equation -> nucleus
      let path: Array<RohanIndex> = TextLocation.parseIndices("[↓1,↓1,nuc]")!
      #expect(validate(TextLocation(path, 0)))
      #expect(validate(TextLocation(path, 1)))
      #expect(validate(TextLocation(path, 2)) == false)
    }
    do {
      // invalid path

      // paragraph -> equation
      let path: Array<RohanIndex> = TextLocation.parseIndices("[↓1,↓1]")!
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
          TextStylesNode(.emph, [TextNode("Fibonacci")]),
          TextNode(" Sequence"),
        ]),
      ParagraphNode([
        TextNode("Fibonacci sequence is defined as follows:"),
        EquationNode(.block, [TextNode("f(n+2)=f(n+1)+f(n),")]),
        TextNode("where "),
        EquationNode(.inline, [TextNode("n")]),
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

      // heading -> emphasis -> text
      let path: Array<RohanIndex> = TextLocation.parseIndices("[↓0,↓0,↓0]")!

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

      // heading -> text -> <offset>
      let location = TextLocation.parse("[↓0,↓2]:1")!
      // paragraph -> text -> <offset>
      let end = TextLocation.parse("[↓1,↓4]:3")!

      // validate
      #expect(validate(location, end) == false)

      // repair
      #expect(repair(location, end) == .failure)
    }
    // Case c)
    do {
      let location = TextLocation.parse("[]:0")!
      // paragraph -> text -> <offset>
      let end = TextLocation.parse("[↓1,↓4]:3")!

      // validate
      #expect(validate(location, end))

      // repair
      let range = RhTextRange(location, end)!
      #expect(repair(range) == .original(range))
    }
    // Case d)
    do {
      // paragraph -> text -> <offset>
      let location = TextLocation.parse("[↓1,↓2]:1")!
      // paragraph -> text -> <offset>
      let end = TextLocation.parse("[↓1,↓4]:3")!

      #expect(validate(location, end))
      // repair
      let range = RhTextRange(location, end)!
      #expect(repair(range) == .original(range))
    }
    // Case e)
    do {

      // paragraph -> equation -> nucleus -> text -> <offset>
      let location = TextLocation.parse("[↓1,↓1,nuc,↓0]:1")!
      // paragraph -> equation -> nucleus -> text -> <offset>
      let end = TextLocation.parse("[↓1,↓3,nuc,↓0]:1")!

      // validate
      #expect(validate(location, end) == false)

      // repair

      // paragraph -> <offset>
      let fixedLocation = TextLocation.parse("[↓1]:1")!
      // paragraph -> <offset>
      let fixedEnd = TextLocation.parse("[↓1]:4")!
      #expect(repair(location, end) == .repaired(RhTextRange(fixedLocation, fixedEnd)!))
    }
    // Case f)
    do {

      // paragraph -> equation -> nucleus -> text -> <offset>
      let location = TextLocation.parse("[↓1,↓1,nuc,↓0]:2")!
      // paragraph -> text -> <offset>
      let end = TextLocation.parse("[↓1,↓4]:3")!

      // validate
      #expect(validate(location, end) == false)
      // repair

      // paragraph -> <offset>
      let fixedLocation = TextLocation.parse("[↓1]:1")!
      #expect(repair(location, end) == .repaired(RhTextRange(fixedLocation, end)!))
    }
  }

  @Test
  static func test_repairRange_FractionNode() {
    let rootNode = RootNode([
      ParagraphNode([
        EquationNode(
          .inline, [FractionNode(num: [], denom: [])])
      ])
    ])

    // paragraph -> equation -> nucleus -> fraction -> numerator -> <offset>
    let location = TextLocation.parse("[↓0,↓0,nuc,↓0,num]:0")!
    let endLocation = TextLocation.parse("[↓0,↓0,nuc,↓0,denom]:0")!

    let range = RhTextRange(location, endLocation)!
    #expect(TreeUtils.validateRange(range, rootNode) == false)

    let result = TreeUtils.repairRange(range, rootNode)
    let repairedRange = result.unwrap()!

    #expect("\(repairedRange)" == "[↓0,↓0,nuc]:0..<[↓0,↓0,nuc]:1")
  }

  @Test
  static func test_repairRange_TextStyles() {
    let rootNode = RootNode([
      ParagraphNode([
        TextNode("The quick brown "),
        TextStylesNode(.emph, [TextNode("fox ")]),
        TextNode("jumps over the lazy dog."),
      ])
    ])

    do {
      let endOffset = "fo".length
      let range = RhTextRange.parse("[↓0]:0..<[↓0,↓1,↓0]:\(endOffset)")!

      #expect(TreeUtils.validateRange(range, rootNode) == false)
      let result = TreeUtils.repairRange(range, rootNode)
      let repairedRange = result.unwrap()!
      #expect("\(repairedRange)" == "[↓0]:0..<[↓0]:2")
    }

    do {
      let offset = "fo".length
      let range = RhTextRange.parse("[↓0,↓1,↓0]:\(offset)..<[↓0]:3")!

      #expect(TreeUtils.validateRange(range, rootNode) == false)
      let result = TreeUtils.repairRange(range, rootNode)
      let repairedRange = result.unwrap()!
      #expect("\(repairedRange)" == "[↓0]:1..<[↓0]:3")
    }
  }
}
