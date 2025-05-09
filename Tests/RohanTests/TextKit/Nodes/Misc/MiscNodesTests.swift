// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct MiscNodesTests {

  static func allSamples() -> [Node] {
    [
      LinebreakNode(),
      TextNode("abc"),
      UnknownNode(JSONValue.number(123)),
    ]
  }
}
