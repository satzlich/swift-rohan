// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct NodesTests {
  @Test
  func coverage() {
    let nodes: [Node] = NodesTests.allSamples()
    let stylesheet = StyleSheetTests.sampleStyleSheet()

    let visitor1 = NaiveNodeVisitor()
    let visitor2 = SimpleNodeVisitor<Void>()

    for node in nodes {
      _ = node.id
      _ = node.type
      node.reallocateId()
      node.prepareForReuse()
      _ = node.firstIndex()
      _ = node.lastIndex()
      _ = node.layoutLength()
      _ = node.isBlock
      _ = node.isDirty
      _ = node.selector()
      _ = node.getProperties(stylesheet)
      node.resetCachedProperties(recursive: false)
      node.resetCachedProperties(recursive: true)
      _ = node.deepCopy()

      node.accept(visitor1, ())
      node.accept(visitor2, ())
    }
  }

  static func allSamples() -> Array<Node> {
    var samples = Array<Node>()

    samples.append(contentsOf: ElementNodeTests.allSamples())
    samples.append(contentsOf: GridNodeTests.allSamples())
    samples.append(contentsOf: UnderOverNodeTests.allSamples())

    return samples
  }

  private final class NaiveNodeVisitor: NodeVisitor<Void, Void> {
    override func visitNode(_ node: Node, _ context: Void) -> Void {
      // no-op
    }
  }
}
