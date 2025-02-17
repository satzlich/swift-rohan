// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

public final class TextNode: Node {
  override class var nodeType: NodeType { .text }

  private(set) var bigString: BigString

  public func getString() -> String { String(bigString) }

  public convenience init<S>(_ string: S)
  where S: Sequence, S.Element == Character {
    self.init(BigString(string))
  }

  public init(_ bigString: BigString) {
    precondition(TextNode.validate(string: bigString))
    self.bigString = bigString
  }

  internal init(_ textNode: TextNode) {
    self.bigString = textNode.bigString
  }

  internal init(deepCopyOf textNode: TextNode) {
    self.bigString = textNode.bigString
  }

  static func validate<S>(string: S) -> Bool
  where S: Sequence, S.Element == Character {
    Text.validate(string: string)
  }

  // MARK: - Content

  override final func getChild(_ index: RohanIndex) -> Node? { return nil }

  final var characterCount: Int { bigString.count }

  // MARK: - Layout

  override final var layoutLength: Int { bigString.utf16.count }

  override final var isBlock: Bool { false }

  override final var isDirty: Bool { false }

  override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    context.insertText(self)
  }

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let offset = index.index() else { return nil }
    return getLayoutOffset(offset)
  }

  private final func getLayoutOffset(_ index: Int) -> Int {
    let target = bigString.index(bigString.startIndex, offsetBy: index)
    return bigString.utf16.distance(from: bigString.utf16.startIndex, to: target)
  }

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, layoutOffset: Int)? {
    guard 0..<layoutLength ~= layoutOffset else { return nil }
    let index = getIndex(layoutOffset)
    let layoutOffset = getLayoutOffset(index)
    return (.index(index), layoutOffset)
  }

  private final func getIndex(_ layoutOffset: Int) -> Int {
    precondition(0..<layoutLength ~= layoutOffset)
    let target = bigString.utf16.index(bigString.utf16.startIndex, offsetBy: layoutOffset)
    return bigString.distance(from: bigString.startIndex, to: target)
  }

  override final func enumerateTextSegments(
    _ context: LayoutContext,
    _ trace: ArraySlice<TraceElement>,
    _ endTrace: ArraySlice<TraceElement>,
    layoutOffset: Int,
    originCorrection: CGPoint,
    type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) {
    guard trace.count == 1,
      endTrace.count == 1,
      let element = trace.first,
      let endElement = endTrace.first,
      // must be identical
      element.node === endElement.node,
      let layoutOffset_ = self.getLayoutOffset(element.index),
      let endOffset_ = self.getLayoutOffset(endElement.index)
    else { return }
    // compute layout range
    let layouRange = (layoutOffset + layoutOffset_)..<(layoutOffset + endOffset_)
    // create new block
    func newBlock(
      _ layoutRange: Range<Int>?, _ segmentFrame: CGRect, _ baselinePosition: CGFloat
    ) -> Bool {
      let segmentFrame = segmentFrame.offsetBy(dx: originCorrection.x, dy: originCorrection.y)
      return block(nil, segmentFrame, baselinePosition)
    }
    // enumerate
    context.enumerateTextSegments(layouRange, type: type, options: options, using: newBlock(_:_:_:))
  }

  override final func getTextLocation(
    interactingAt point: CGPoint, _ context: LayoutContext, _ path: inout [RohanIndex]
  ) -> Bool {
    // do nothing
    return false
  }

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(text: self, context)
  }
}
