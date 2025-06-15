// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct TemplateNodesTests {

  static func allSamples() -> Array<Node> {
    [
      VariableNode(1),
      ApplyNode(MathTemplate.pmod, [[]])!
    ]
  }
}
