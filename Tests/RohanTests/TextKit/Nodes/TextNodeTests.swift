// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct TextNodeTests {
  @Test
  static func testValidation() {
    #expect(TextExpr.validate(string: "ABC\r\nxyz") == false)
    #expect(TextExpr.validate(string: "ABC\rxyz") == false)
    #expect(TextExpr.validate(string: "ABC\nxyz") == false)
    #expect(TextExpr.validate(string: "ABCxyz") == true)
  }

  @Test
  static func test_isBlock() {
    let textNode = TextNode("Abc")
    #expect(textNode.isBlock == false)
  }

  @Test
  static func test_stringLength() {
    let textNode = TextNode("ab😀")
    #expect(textNode.stringLength == 4)
  }

  @Test
  static func test_layoutLength() {
    let textNode = TextNode("ab😀")
    #expect(textNode.layoutLength == 4)
  }

  @Test
  static func test_getLayoutOffset() {
    let textNode = TextNode("ab😀")
    #expect(textNode.getLayoutOffset(.index(2)) == 2)
    #expect(textNode.getLayoutOffset(.index(3)) == 3)
    #expect(textNode.getLayoutOffset(.index(4)) == 4)
  }

  @Test
  static func test_getRohanIndex() {
    let textNode = TextNode("ab😀c")
    #expect(textNode.getRohanIndex(2)! == (RohanIndex.index(2), 2))
    #expect(textNode.getRohanIndex(3)! == (RohanIndex.index(2), 2))
    #expect(textNode.getRohanIndex(4)! == (RohanIndex.index(4), 4))
  }

  @Test
  static func test_destinationOffset() {
    let textNode = TextNode("ab😀c")
    // forward
    #expect(textNode.destinationOffset(for: 0, offsetBy: 1) == 1)
    #expect(textNode.destinationOffset(for: 1, offsetBy: 1) == 2)
    #expect(textNode.destinationOffset(for: 2, offsetBy: 1) == 4)
    #expect(textNode.destinationOffset(for: 3, offsetBy: 1) == 4)
    #expect(textNode.destinationOffset(for: 4, offsetBy: 1) == 5)
    #expect(textNode.destinationOffset(for: 5, offsetBy: 1) == nil)

    // backward
    #expect(textNode.destinationOffset(for: 5, offsetBy: -1) == 4)
    #expect(textNode.destinationOffset(for: 4, offsetBy: -1) == 2)
    #expect(textNode.destinationOffset(for: 3, offsetBy: -1) == 1)
    #expect(textNode.destinationOffset(for: 2, offsetBy: -1) == 1)
    #expect(textNode.destinationOffset(for: 1, offsetBy: -1) == 0)
    #expect(textNode.destinationOffset(for: 0, offsetBy: -1) == nil)
  }
}
