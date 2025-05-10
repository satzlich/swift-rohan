// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct NodesTests {

  static var uncoveredTypes: Set<NodeType> = [.argument, .apply, .cVariable]

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

      //
      node.accept(visitor1, ())
      node.accept(visitor2, ())

      //
      _ = node.prettyPrint()
      _ = node.debugPrint()
      _ = node.layoutLengthSynopsis()
    }

    // check types
    let uncoveredTypes = Set(NodeType.allCases).subtracting(Set(nodes.map(\.type)))
    #expect(uncoveredTypes == [.apply, .argument, .cVariable])
  }

  static func allSamples() -> Array<Node> {
    var nodes = Array<Node>()

    nodes.append(contentsOf: ElementNodeTests.allSamples())
    nodes.append(contentsOf: GridNodeTests.allSamples())
    nodes.append(contentsOf: UnderOverNodeTests.allSamples())
    nodes.append(contentsOf: MathNodesTests.allSamples())
    nodes.append(contentsOf: MathMiscNodesTests.allSamples())
    nodes.append(contentsOf: TemplateNodesTests.allSamples())
    nodes.append(contentsOf: MiscNodesTests.allSamples())

    return nodes
  }

  private final class NaiveNodeVisitor: NodeVisitor<Void, Void> {
    override func visitNode(_ node: Node, _ context: Void) -> Void {
      // no-op
    }
  }
}
