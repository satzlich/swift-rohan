// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

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
          StrongNode(.emph, [TextNode("world!")]),
        ]),
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
    ])
    let documentManager = createDocumentManager(rootNode)

    // heading -> text -> "Hel"
    let location = TextLocation.compose("[↓0,↓0]", "Hel".length)!

    do {
      // heading -> emphasis -> text -> "world"
      let endLocation = TextLocation.compose("[↓0,↓1,↓0]", "world".length)!
      let range = RhTextRange(location, endLocation)!

      // serialize
      let data = documentManager.jsonData(for: range)!
      #expect(
        String(data: data, encoding: .utf8) == """
          [{"string":"lo, ","type":"text"},{"children":[{"string":"world","type":"text"}],"command":"emph","type":"textStyles"}]
          """)

      // deserialize
      let decodedNodes: ElementStore = try NodeSerdeUtils.decodeListOfNodes(from: data)
      #expect(
        ContentNode(decodedNodes).prettyPrint() == """
          content
          ├ text "lo, "
          └ textStyles(emph)
            └ text "world"
          """)
    }

    do {
      // paragraph -> text -> "The quick"
      let endLocation = TextLocation.compose("[↓1,↓0]", "The quick".length)!
      let range = RhTextRange(location, endLocation)!
      let data = documentManager.jsonData(for: range)!

      #expect(
        String(data: data, encoding: .utf8) == """
          [{"children":[{"string":"lo, ","type":"text"},{"children":[{"string":"world!","type":"text"}],"command":"emph","type":"textStyles"}],"level":1,"type":"heading"},{"children":[{"string":"The quick","type":"text"}],"type":"paragraph"}]
          """)

      // deserialize
      let decodedNodes: ElementStore = try NodeSerdeUtils.decodeListOfNodes(from: data)
      #expect(
        ContentNode(decodedNodes).prettyPrint() == """
          content
          ├ heading
          │ ├ text "lo, "
          │ └ textStyles(emph)
          │   └ text "world!"
          └ paragraph
            └ text "The quick"
          """)
    }
  }
}
