// Copyright 2024-2025 Lie Yan

import Foundation

extension TreeUtils {
  /// Returns content properties of the expression list.
  static func contentProperty(of exprs: Array<Expr>) -> Array<ContentProperty> {
    let nodes: Array<Node> = NodeUtils.convertExprs(exprs)
    return nodes.flatMap { $0.contentProperty() }
  }

  /// Returns content properties of the node list.
  static func contentProperty(of nodes: Array<Node>) -> Array<ContentProperty> {
    nodes.flatMap { $0.contentProperty() }
  }

  static func containerProperty(
    for location: TextLocation, _ tree: RootNode
  ) -> ContainerProperty? {
    Trace.from(location, tree).flatMap { trace in
      containerProperty(of: trace.last!.node)
    }
  }

  /// Returns the category of content container that the node __is__ or __is in__.
  /// Returns nil if no consistent category can be found.
  static func containerProperty(of node: Node) -> ContainerProperty? {
    var p: Node? = node

    while p != nil {
      if let argumentNode = p as? ArgumentNode {
        return argumentNode.computeContainerProperty()
      }
      else if let containerProperty = p?.containerProperty() {
        return containerProperty
      }
      else {
        p = p?.parent
      }
    }
    return nil
  }
}
