// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct TextNodeTests {
  @Test
  static func testValidation() {
    #expect(Text.validate(string: "ABC\r\nxyz") == false)
    #expect(Text.validate(string: "ABC\rxyz") == false)
    #expect(Text.validate(string: "ABC\nxyz") == false)
    #expect(Text.validate(string: "ABCxyz") == true)
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
}
