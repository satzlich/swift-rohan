import Foundation
import Testing

@testable import SwiftRohan

struct NodesTests {
  static let uncoveredNodeTypes: Set<NodeType> = [.argument, .cVariable, .expansion]

  @Test
  func coverage() {
    let nodes: Array<Node> = NodesTests.allSamples()
    let stylesheet = StyleSheetTests.testingStyleSheet()

    let visitor1 = NaiveNodeVisitor()
    let visitor2 = SimpleNodeVisitor<Void>()

    for node in nodes {
      _ = node.id
      _ = node.type
      node.reallocateId()
      node.resetCachedProperties()
      node.resetForReuse()
      _ = node.firstIndex()
      _ = node.lastIndex()
      _ = node.layoutLength()
      _ = node.layoutType
      _ = node.isDirty
      _ = node.selector()
      _ = node.getProperties(stylesheet)
      _ = node.deepCopy()

      //
      node.accept(visitor1, ())
      node.accept(visitor2, ())

      //
      _ = node.prettyPrint()
      _ = node.debugPrint()
      _ = node.layoutLengthSynopsis()

      // Store/Load
      if [NodeType.argument, .variable, .content].contains(node.type) == false {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let storeData = node.store()
        let json = try! encoder.encode(storeData)
        let loaded = NodeStoreUtils.loadNode(storeData)

        #expect(loaded.isSuccess || node.type == .unknown)
        #expect(node.type == loaded.unwrap().type)

        let storeData2 = loaded.unwrap().store()
        let json2 = try! encoder.encode(storeData2)
        #expect(storeData == storeData2)
        #expect(json == json2)
      }
    }

    // check types
    let uncoveredTypes = Set(NodeType.allCases).subtracting(Set(nodes.map(\.type)))
    #expect(uncoveredTypes == NodesTests.uncoveredNodeTypes)
  }

  static func allSamples() -> Array<Node> {
    var nodes = Array<Node>()

    nodes.append(contentsOf: ElementNodeTests.allSamples())
    nodes.append(contentsOf: ArrayNodeTests.allSamples())
    nodes.append(contentsOf: MathNodeTests.allSamples())
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
