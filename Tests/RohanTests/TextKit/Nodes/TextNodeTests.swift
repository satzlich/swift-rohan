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
    let text = TextNode("Abc")
    #expect(text.isBlock == false)
  }

  @Test
  static func test_characterCount() {
    let text = TextNode("ab😀")
    #expect(text.stringLength == 3)
  }

  @Test
  static func test_layoutLength() {
    let text = TextNode("ab😀")
    #expect(text.layoutLength == 4)
  }

  @Test
  static func test_getLayoutOffset() {
    let text = TextNode("ab😀")
    #expect(text.getLayoutOffset(.index(2)) == 2)
    #expect(text.getLayoutOffset(.index(3)) == 4)
    #expect(text.getLayoutOffset(.index(4)) == nil)
  }

  @Test
  static func test_getRohanIndex() {
    let text = TextNode("ab😀c")
    #expect(text.getRohanIndex(2)! == (RohanIndex.index(2), 2))
    #expect(text.getRohanIndex(3)! == (RohanIndex.index(2), 2))
    #expect(text.getRohanIndex(4)! == (RohanIndex.index(3), 4))
  }
}
