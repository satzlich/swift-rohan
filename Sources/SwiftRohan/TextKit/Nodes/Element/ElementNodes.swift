// Copyright 2024-2025 Lie Yan

import DequeModule
import Foundation

public final class RootNode: ElementNode {
  override class var type: NodeType { .root }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(root: self, context)
  }
}

public class ContentNode: ElementNode {
  override final class var type: NodeType { .content }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(content: self, context)
  }

  override public func deepCopy() -> ContentNode { ContentNode(deepCopyOf: self) }
  override func cloneEmpty() -> ContentNode { ContentNode() }
}

public final class ParagraphNode: ElementNode {
  override class var type: NodeType { .paragraph }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(paragraph: self, context)
  }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }
  override func createSuccessor() -> ElementNode? { ParagraphNode() }
}

public final class HeadingNode: ElementNode {
  override class var type: NodeType { .heading }

  typealias Subtype = HeadingExpr.Subtype

  public let level: Int

  var subtype: Subtype { Subtype(level: level) }

  public init(level: Int, _ children: [Node]) {
    precondition(HeadingExpr.validate(level: level))
    self.level = level
    super.init(Store(children))
  }

  internal init(deepCopyOf headingNode: HeadingNode) {
    self.level = headingNode.level
    super.init(deepCopyOf: headingNode)
  }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(heading: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case level }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    level = try container.decode(Int.self, forKey: .level)
    try super.init(from: decoder)
  }

  public override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(level, forKey: .level)
    try super.encode(to: encoder)
  }

  internal override func encode<S: Collection<PartialNode>>(
    to encoder: any Encoder, withChildren children: S
  ) throws where S: Encodable {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(level, forKey: .level)
    try super.encode(to: encoder, withChildren: children)
  }

  // MARK: - Content

  override func cloneEmpty() -> Self { Self(level: level, []) }
  override func createSuccessor() -> ElementNode? { ParagraphNode() }

  // MARK: - Styles

  override public func selector() -> TargetSelector {
    HeadingNode.selector(level: level)
  }

  public static func selector(level: Int? = nil) -> TargetSelector {
    precondition(level == nil || HeadingExpr.validate(level: level!))
    guard let level else { return TargetSelector(.heading) }
    return TargetSelector(.heading, PropertyMatcher(.level, .integer(level)))
  }
}

public final class EmphasisNode: ElementNode {
  override class var type: NodeType { .emphasis }

  override public func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    func invert(fontStyle: FontStyle) -> FontStyle {
      switch fontStyle {
      case .normal: return .italic
      case .italic: return .normal
      }
    }

    if _cachedProperties == nil {
      // inherit properties
      var properties = super.getProperties(styleSheet)
      // invert font style
      let key = TextProperty.style
      let value = key.resolve(properties, styleSheet.defaultProperties).fontStyle()!
      properties[key] = .fontStyle(invert(fontStyle: value))
      // cache properties
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(emphasis: self, context)
  }
}

public final class StrongNode: ElementNode {
  override class var type: NodeType { .strong }

  override public func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      // inherit properties
      var properties = super.getProperties(styleSheet)
      // invert font style
      let key = TextProperty.weight
      properties[key] = .fontWeight(.bold)
      // cache properties
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }
  override func cloneEmpty() -> Self { Self() }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(strong: self, context)
  }
}
