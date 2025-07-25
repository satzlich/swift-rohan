import Foundation
import Testing

@testable import SwiftRohan

struct TemplateNodesTests {

  static func allSamples() -> Array<Node> {
    [
      VariableNode(1, .textit, .inline),
      ApplyNode(MathTemplate.pmod, [[]])!,
    ]
  }
}
