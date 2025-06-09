// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

final class RootNode: ElementNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(root: self, context)
  }

  final override class var type: NodeType { .root }

//  // MARK: - Node(Positioning)
//
//  final override func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
//    let layoutLength = super.layoutLength()
//    guard 0...layoutLength + 1 ~= layoutOffset else { return nil }
//
//    let layoutOffset = layoutOffset.clamped(0, layoutLength)
//    return super.getRohanIndex(layoutOffset)
//  }
//
//  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
//    let layoutLength = super.layoutLength()
//    guard 0...layoutLength + 1 ~= layoutOffset else {
//      return .failure(error: SatzError(.InvalidLayoutOffset))
//    }
//    let layoutOffset = layoutOffset.clamped(0, layoutLength)
//    return super.getPosition(layoutOffset)
//  }

//  // MARK: - Node(Layout)
//
//  final override func layoutLength() -> Int { super.layoutLength() + 1 }
//
//  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) -> Int {
//    if fromScratch {
//      context.insertNewline(self)
//    }
//    else {
//      context.skipBackwards(1)
//    }
//    let sum = super.performLayout(context, fromScratch: fromScratch)
//
//    // add paragraph style to avoid unexpected paragraph alignment
//    context.addParagraphStyle(self, sum..<sum + 1)
//
//    return sum + 1
//  }

  // MARK: - Node(Storage)

  private static let uniqueTag = "document"

  final override class var storageTags: Array<String> { [uniqueTag] }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue {
    let children: [JSONValue] = childrenReadonly().map { $0.store() }
    let json = JSONValue.array([.string(Self.uniqueTag), .array(children)])
    return json
  }

  // MARK: - ElementNode

  final override func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    visitor.visit(root: self, context, withChildren: children)
  }

  override func cloneEmpty() -> Self { Self() }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<RootNode> {
    guard let children = NodeStoreUtils.takeChildrenArray(json, uniqueTag)
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }

}
