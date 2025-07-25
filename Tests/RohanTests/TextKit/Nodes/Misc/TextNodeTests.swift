import Foundation
import Testing

@testable import SwiftRohan

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
    #expect(textNode.layoutType == .inline)
  }

  @Test
  static func test_stringLength() {
    let textNode = TextNode("ab😀")
    #expect(textNode.length == 4)
  }

  @Test
  static func test_layoutLength() {
    let textNode = TextNode("ab😀")
    #expect(textNode.layoutLength() == 4)
  }

  @Test
  static func test_getLayoutOffset() {
    let textNode = TextNode("ab😀")
    #expect(textNode.getLayoutOffset(.index(2)) == 2)
    #expect(textNode.getLayoutOffset(.index(3)) == 3)
    #expect(textNode.getLayoutOffset(.index(4)) == 4)
  }

  @Test
  static func test_getPosition() {
    let textNode = TextNode("ab😀c")
    #expect(
      textNode.getPosition(2) == PositionResult.terminal(value: .index(2), target: 2))
    #expect(
      textNode.getPosition(3) == PositionResult.terminal(value: .index(2), target: 2))
    #expect(
      textNode.getPosition(4) == PositionResult.terminal(value: .index(4), target: 4))
  }

  @Test
  static func test_destinationOffset() {
    let textNode = TextNode("ab😀c")
    // forward
    #expect(textNode.destinationOffset(for: 0, cOffsetBy: 1) == 1)
    #expect(textNode.destinationOffset(for: 1, cOffsetBy: 1) == 2)
    #expect(textNode.destinationOffset(for: 2, cOffsetBy: 1) == 4)
    #expect(textNode.destinationOffset(for: 3, cOffsetBy: 1) == 4)
    #expect(textNode.destinationOffset(for: 4, cOffsetBy: 1) == 5)
    #expect(textNode.destinationOffset(for: 5, cOffsetBy: 1) == nil)

    // backward
    #expect(textNode.destinationOffset(for: 5, cOffsetBy: -1) == 4)
    #expect(textNode.destinationOffset(for: 4, cOffsetBy: -1) == 2)
    #expect(textNode.destinationOffset(for: 3, cOffsetBy: -1) == 1)
    #expect(textNode.destinationOffset(for: 2, cOffsetBy: -1) == 1)
    #expect(textNode.destinationOffset(for: 1, cOffsetBy: -1) == 0)
    #expect(textNode.destinationOffset(for: 0, cOffsetBy: -1) == nil)
  }
}
