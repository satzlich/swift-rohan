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

    guard let data = documentContent.writeData(format: .rohan) else {
      Issue.record("Failed to serialize DocumentContent")
      return
    }

    guard let decodedContent = DocumentContent.readFrom(data) else {
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

  @Test
  func decodeThrows() {
    do {
      let json = """
        (]
        """
      let data = Data(json.utf8)
      #expect(nil == DocumentContent.readFrom(data))
    }
    do {
      let json = """
        [["unsupported"]]
        """
      let data = Data(json.utf8)
      #expect(nil == DocumentContent.readFrom(data))
    }
  }
}
