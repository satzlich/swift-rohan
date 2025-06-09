// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct ResolveLocationTests {
  @Test
  func getPosition() {
    do {
      let textNode = TextNode("Hello, World!")
      let offset = 5
      let result = textNode.getPosition(offset)

      #expect(result.isTerminal)
      #expect(result.value == .index(offset))
      #expect(result.offset == offset)
    }

    do {
      let elementNodes = [
        HeadingNode(level: 1, []),
        ParagraphNode([]),
      ]
      for node in elementNodes {
        TestUtils.updateLayoutLength(node)
        do {
          let offset = 0
          let result = node.getPosition(offset)
          #expect(result.isTerminal)
          #expect(result.value == .index(offset))
          #expect(result.offset == offset)
        }

        if NodePolicy.isPlaceholderEnabled(node.type) {
          let offset = 1
          let result = node.getPosition(offset)
          #expect(result.isTerminal)
          #expect(result.value == .index(0))
          #expect(result.offset == 0)
        }
        else {
          let offset = 1
          let result = node.getPosition(offset)
          #expect(result.isFailure)
        }
      }
    }

    do {
      let elementNodes = [
        HeadingNode(
          level: 1,
          [
            TextNode("Hello"),
            LinebreakNode(),
            TextNode("World"),
          ]),
        ParagraphNode([
          TextNode("Hello"),
          LinebreakNode(),
          TextNode("World"),
        ]),
      ]
      for node in elementNodes {
        TestUtils.updateLayoutLength(node)

        do {
          let offset = 0
          let result = node.getPosition(offset)
          #expect(result.isHalfway)
          #expect(result.value == .index(0))
          #expect(result.offset == 0)
        }
        do {
          let offset = 1
          let result = node.getPosition(offset)
          #expect(result.isHalfway)
          #expect(result.value == .index(0))
          #expect(result.offset == 0)
        }
        do {
          let offset = 5
          let result = node.getPosition(offset)
          #expect(result.isHalfway)
          #expect(result.value == .index(1))
          #expect(result.offset == 5)
        }
        do {
          let offset = 6
          let result = node.getPosition(offset)
          #expect(result.isHalfway)
          #expect(result.value == .index(2))
          #expect(result.offset == 6)
        }
        do {
          let offset = 7
          let result = node.getPosition(offset)
          #expect(result.isHalfway)
          #expect(result.value == .index(2))
          #expect(result.offset == 6)
        }
        do {
          let offset = 11
          let result = node.getPosition(offset)
          #expect(result.isTerminal)
          #expect(result.value == .index(3))
          #expect(result.offset == 11)
        }
      }
    }
  }
}
