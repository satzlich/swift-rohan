// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

final class PartialNodeSerdeTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  @Test
  func test_PartialNode() throws {
    // create document manager
    let rootNode = RootNode([
      HeadingNode(
        level: 1,
        [
          TextNode("Hello, "),
          EmphasisNode([TextNode("world!")]),
        ]),
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
    ])
    let documentManager = createDocumentManager(rootNode)

    let location: TextLocation = {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // text
      ]
      return TextLocation(path, "Hel".llength)
    }()

    do {
      // create range
      let endPath: [RohanIndex] = [
        .index(0),  // paragraph
        .index(1),  // emphasis
        .index(0),  // text
      ]
      let endLocation = TextLocation(endPath, "world".llength)
      let range = RhTextRange(location, endLocation)!

      // serialize
      let data = documentManager.jsonData(for: range)!
      #expect(
        String(data: data, encoding: .utf8) == """
          [{"string":"lo, ","type":"text"},\
          {"children":[{"string":"world","type":"text"}],"type":"emphasis"}]
          """)

      // deserialize
      let decodedNodes: [Node] = try NodeSerdeUtils.decodeListOfNodes(from: data)
      #expect(
        ContentNode(decodedNodes).prettyPrint() == """
          content
          ├ text "lo, "
          └ emphasis
            └ text "world"
          """)

      // get string
      let string = documentManager.stringify(for: range)!
      #expect(string == "lo, world")
    }

    do {
      let endPath: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let endLocation = TextLocation(endPath, "The quick".llength)
      let range = RhTextRange(location, endLocation)!

      let data = documentManager.jsonData(for: range)!

      #expect(
        String(data: data, encoding: .utf8) == """
          [{"children":[{"string":"lo, ","type":"text"},\
          {"children":[{"string":"world!","type":"text"}],"type":"emphasis"}],\
          "level":1,"type":"heading"},\
          {"children":[{"string":"The quick","type":"text"}],"type":"paragraph"}]
          """)

      // deserialize
      let decodedNodes: [Node] = try NodeSerdeUtils.decodeListOfNodes(from: data)
      #expect(
        ContentNode(decodedNodes).prettyPrint() == """
          content
          ├ heading
          │ ├ text "lo, "
          │ └ emphasis
          │   └ text "world!"
          └ paragraph
            └ text "The quick"
          """)

      // get string
      let string = documentManager.stringify(for: range)!
      #expect(string == "lo, world!\nThe quick")
    }
  }
}
