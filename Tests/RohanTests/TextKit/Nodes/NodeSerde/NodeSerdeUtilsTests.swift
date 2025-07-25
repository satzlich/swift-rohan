import Foundation
import Testing

@testable import SwiftRohan

struct NodeSerdeUtilsTests {
  // This test ensures that all nodes are registered in the
  // NodeSerdeUtils.registeredNodes dictionary.
  @Test
  static func registeredNodes() {
    let unregistered = NodeType.complementSet(to: NodeSerdeUtils.registeredNodes.keys)
    #expect(unregistered == [.cVariable])
  }

  @Test
  func unknownNodes() throws {
    let testCases: Array<String> = [
      "null",
      "true",
      "false",
      "1",
      "1.1",
      """
      [1,2,3]
      """,
      """
      {"a":1,"c":1.1}
      """,
    ]

    for (i, json) in testCases.enumerated() {
      try testRoundTrip(json, i)
    }

    func testRoundTrip(_ json: String, _ i: Int) throws {
      // decode
      let decoded = try NodeSerdeUtils.decodeNode(from: Data(json.utf8))
      #expect(decoded is UnknownNode, "Test case \(i)")

      // encode
      let encoder = JSONEncoder()
      encoder.outputFormatting = .sortedKeys
      let encoded = try encoder.encode(decoded)
      #expect(String(data: encoded, encoding: .utf8) == json, "Test case \(i)")
    }
  }

  @Test
  func listOfListsOfNodes() throws {
    let json = """
      [[{"string":"a","type":"text"}],[{"string":"b","type":"text"}]]
      """
    let decoded: [Array<Node>] =
      try NodeSerdeUtils.decodeListOfListsOfNodes(from: Data(json.utf8))

    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let encoded = try encoder.encode(decoded)
    #expect(String(data: encoded, encoding: .utf8) == json)
  }
}
