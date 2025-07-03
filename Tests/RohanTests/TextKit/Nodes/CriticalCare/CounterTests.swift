// Copyright 2024-2025 Lie Yan

import Algorithms
import CoreGraphics
import DequeModule
import Testing

@testable import SwiftRohan

struct CounterTests {
  @Test
  func construction() {
    let rootNode = RootNode([
      ParagraphNode([
        TextNode("Plaintext")
      ]),
      HeadingNode(
        .section,
        [
          TextNode("Emit HeadingNode")
        ]),
      ParagraphNode([
        TextNode("Plaintext")
      ]),
      HeadingNode(
        .subsection,
        [
          TextNode("Emit HeadingNode with subsection")
        ]),
      ParagraphNode([
        TextNode("Plaintext")
      ]),
    ])

    guard let counterSegment = rootNode.counterSegment else {
      Issue.record("Counter segment is nil")
      return
    }

    do {
      let begin = counterSegment.begin
      let end = counterSegment.end
      #expect(CountHolder.countSubrange(begin, inclusive: end) == 2)
      #expect(begin.value(forName: .section) == 1)
      #expect(begin.value(forName: .subsection) == 0)
      #expect(end.value(forName: .section) == 1)
      #expect(end.value(forName: .subsection) == 1)
    }
  }
}
