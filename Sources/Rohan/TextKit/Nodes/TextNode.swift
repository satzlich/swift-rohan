// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

public final class TextNode: Node {
  override class var nodeType: NodeType { .text }

  private let _bigString: BigString
  var bigString: BigString { @inline(__always) get { _bigString } }

  public func getString() -> String { String(_bigString) }

  public convenience init<S>(_ string: S)
  where S: Sequence, S.Element == Character {
    self.init(BigString(string))
  }

  public init(_ bigString: BigString) {
    precondition(TextNode.validate(string: bigString))
    self._bigString = bigString
  }

  internal init(_ textNode: TextNode) {
    self._bigString = textNode._bigString
  }

  internal init(deepCopyOf textNode: TextNode) {
    self._bigString = textNode._bigString
  }

  static func validate<S>(string: S) -> Bool
  where S: Sequence, S.Element == Character {
    Text.validate(string: string)
  }

  // MARK: - Content

  override final func getChild(_ index: RohanIndex) -> Node? {
    return nil
  }
  final var characterCount: Int { _bigString.count }

  // MARK: - Layout

  override final var layoutLength: Int { _bigString.utf16.count }

  override final var isBlock: Bool { false }

  override final var isDirty: Bool { false }

  override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    context.insertText(self)
  }

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(text: self, context)
  }
}
