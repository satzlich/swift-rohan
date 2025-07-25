import Foundation
import Testing

@testable import SwiftRohan

struct MiscNodesTests {

  static func allSamples() -> Array<Node> {
    [
      CounterNode(.equation),
      LinebreakNode(),
      TextNode("abc"),
      UnknownNode(JSONValue.number(123)),
    ]
  }
}
