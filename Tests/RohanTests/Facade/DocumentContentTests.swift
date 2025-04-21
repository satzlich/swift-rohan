// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct DocumentContentTests {
  @Test
  func testBasic() {
    let rootNode = RootNode([
      ParagraphNode([TextNode("Hello")])
    ])
    let documentContent = DocumentContent(rootNode)

    guard let data = documentContent.data()
    else {
      Issue.record("Failed to serialize DocumentContent")
      return
    }

    guard let decodedContent = DocumentContent.from(data)
    else {
      Issue.record("Failed to deserialize DocumentContent")
      return
    }
    #expect(
      decodedContent.rootNode.prettyPrint() == """
        root
        └ paragraph
          └ text "Hello"
        """)

  }

  @Test
  func testEmpty() {
    let documentContent = DocumentContent()

    #expect(
      documentContent.rootNode.prettyPrint() == """
        root
        └ paragraph
        """)
  }
}
