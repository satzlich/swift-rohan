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
    #expect(text.characterCount == 3)
  }

  @Test
  static func test_layoutLength() {
    let text = TextNode("ab😀")
    #expect(text.layoutLength == 4)
  }
}
