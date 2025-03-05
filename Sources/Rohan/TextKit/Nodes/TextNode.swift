// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

public final class TextNode: Node {
  override class var nodeType: NodeType { .text }

  let bigString: BigString

  public convenience init<S>(_ string: S) where S: Sequence, S.Element == Character {
    self.init(BigString(string))
  }

  private init(_ bigString: BigString) {
    precondition(TextNode.validate(string: bigString))
    self.bigString = bigString
  }

  internal init(deepCopyOf textNode: TextNode) {
    self.bigString = textNode.bigString
  }

  internal static func validate<S>(string: S) -> Bool
  where S: Sequence, S.Element == Character {
    Text.validate(string: string)
  }

  // MARK: - Content

  override final func getChild(_ index: RohanIndex) -> Node? { return nil }

  final var stringLength: Int { bigString.utf16.count }

  // MARK: - Location

  /** Move offset by `n` __characters__ */
  final func destinationOffset(for layoutOffset: Int, offsetBy n: Int) -> Int? {
    precondition(0...bigString.utf16.count ~= layoutOffset)
    // convert to the character index
    let utf16Index = bigString.utf16.index(bigString.utf16.startIndex, offsetBy: layoutOffset)
    let charIndex = bigString.distance(from: bigString.startIndex, to: utf16Index)
    // move and check
    let targetIndex = charIndex + n
    guard 0...bigString.count ~= targetIndex else { return nil }
    // convert back
    let target = bigString.index(bigString.startIndex, offsetBy: targetIndex)
    return bigString.utf16.distance(from: bigString.utf16.startIndex, to: target)
  }

  override func firstIndex() -> RohanIndex? { .index(0) }

  override func lastIndex() -> RohanIndex? { .index(stringLength) }

  // MARK: - Layout

  override final var layoutLength: Int { bigString.utf16.count }

  override final var isBlock: Bool { false }

  override final var isDirty: Bool { false }

  override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    context.insertText(self)
  }

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let offset = index.index(),
      0...stringLength ~= offset  // inclusive
    else { return nil }
    return offset
  }

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    guard 0..<layoutLength ~= layoutOffset else { return nil }
    let index = _getUpstreamBoundary(layoutOffset)
    return (.index(index), index)
  }

  /**
   Returns the index of the character at the given layout offset.

   - Note: ``getIndex(_:)`` differs from ``getRohanIndex(_:)`` in that the former
   considers `layoutLength` as valid while the latter does not.
   */
  final func getIndex(_ layoutOffset: Int) -> Int? {
    guard 0...layoutLength ~= layoutOffset else { return nil }
    return _getUpstreamBoundary(layoutOffset)
  }

  /**Returns the upstream boundary of the given layout offset. If the layout offset
   is already an upstream boundary, it returns the same value.*/
  private final func _getUpstreamBoundary(_ layoutOffset: Int) -> Int {
    precondition(0...bigString.utf16.count ~= layoutOffset)
    // convert to the character index
    let utf16Index = bigString.utf16.index(bigString.utf16.startIndex, offsetBy: layoutOffset)
    let charIndex = bigString.distance(from: bigString.startIndex, to: utf16Index)
    // convert back
    let target = bigString.index(bigString.startIndex, offsetBy: charIndex)
    return bigString.utf16.distance(from: bigString.utf16.startIndex, to: target)
  }

  override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: (RhTextRange?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    guard path.count == 1,
      endPath.count == 1,
      let first = self.getLayoutOffset(path[path.startIndex]),
      let last = self.getLayoutOffset(endPath[endPath.startIndex])
    else { return false }
    // compute layout range
    let layouRange = (layoutOffset + first)..<(layoutOffset + last)
    // create new block
    func newBlock(
      _ layoutRange: Range<Int>?, _ segmentFrame: CGRect, _ baselinePosition: CGFloat
    ) -> Bool {
      let segmentFrame = segmentFrame.offsetBy(dx: originCorrection.x, dy: originCorrection.y)
      return block(nil, segmentFrame, baselinePosition)
    }
    // enumerate
    return context.enumerateTextSegments(
      layouRange, type: type, options: options, using: newBlock(_:_:_:))
  }

  override final func resolveTextLocation(
    interactingAt point: CGPoint, _ context: LayoutContext, _ trace: inout [TraceElement]
  ) -> Bool {
    // do nothing
    return false
  }

  override func rayshoot(
    from path: ArraySlice<RohanIndex>,
    _ direction: TextSelectionNavigation.Direction,
    _ context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    guard path.count == 1,
      let localOffset = self.getLayoutOffset(path[path.startIndex])
    else { return nil }
    // compute target layout offset
    let targetOffset = layoutOffset + localOffset
    // perform rayshooting
    return context.rayshoot(from: targetOffset, direction)
  }

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(text: self, context)
  }
}
