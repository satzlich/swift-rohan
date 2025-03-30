// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

public final class TextNode: Node {
  override class var type: NodeType { .text }

  private let _string: BigString

  public convenience init<S>(_ string: S) where S: Sequence, S.Element == Character {
    self.init(BigString(string))
  }

  private init(_ bigString: BigString) {
    precondition(!bigString.isEmpty && Self.validate(string: bigString))
    self._string = bigString
    super.init()
  }

  internal init(deepCopyOf textNode: TextNode) {
    self._string = textNode._string
    super.init()
  }

  static func validate<S>(string: S) -> Bool where S: Sequence, S.Element == Character {
    TextExpr.validate(string: string)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case string }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let string = try container.decode(BigString.self, forKey: .string)
    guard Self.validate(string: string) else {
      throw DecodingError.dataCorruptedError(
        forKey: .string, in: container,
        debugDescription: "Invalid text string.")
    }
    self._string = string
    try super.init(from: decoder)
  }

  public override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_string, forKey: .string)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override final func getChild(_ index: RohanIndex) -> Node? { return nil }

  override final func stringify() -> BigString { _string }

  // MARK: - Location

  /// Move offset by n __characters__
  final func destinationOffset(for layoutOffset: Int, cOffsetBy n: Int) -> Int? {
    precondition(0..._string.utf16.count ~= layoutOffset)
    // convert to the character index
    let utf16Index = _string.utf16.index(_string.utf16.startIndex, offsetBy: layoutOffset)
    let charIndex = _string.distance(from: _string.startIndex, to: utf16Index)
    // move and check
    let targetIndex = charIndex + n
    guard 0..._string.count ~= targetIndex else { return nil }
    // convert back
    let target = _string.index(_string.startIndex, offsetBy: targetIndex)
    return _string.utf16.distance(from: _string.utf16.startIndex, to: target)
  }

  override func firstIndex() -> RohanIndex? { .index(0) }

  override func lastIndex() -> RohanIndex? { .index(u16length) }

  // MARK: - Layout

  override final var layoutLength: Int { _string.utf16.count }

  override final var isBlock: Bool { false }

  override final var isDirty: Bool { false }

  override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    context.insertText(_string, self)
  }

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let offset = index.index(),
      0...layoutLength ~= offset  // inclusive
    else { return nil }
    return offset
  }

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    guard 0..<layoutLength ~= layoutOffset else { return nil }
    let index = _getUpstreamBoundary(layoutOffset)
    return (.index(index), index)
  }

  /// Returns the index of the character at the given layout offset.
  /// - Note: ``getIndex(_:)`` differs from ``getRohanIndex(_:)`` in that the
  ///     former considers the case of `layoutOffset == layoutLength` as valid
  ///     while the latter does not.
  final func getIndex(_ layoutOffset: Int) -> Int? {
    guard 0...layoutLength ~= layoutOffset else { return nil }
    return _getUpstreamBoundary(layoutOffset)
  }

  /// Returns the upstream boundary of the given layout offset. If the layout
  /// offset is already an upstream boundary, it returns the same value.
  private final func _getUpstreamBoundary(_ layoutOffset: Int) -> Int {
    precondition(0..._string.utf16.count ~= layoutOffset)
    // convert to the character index
    let utf16Index = _string.utf16.index(_string.utf16.startIndex, offsetBy: layoutOffset)
    let charIndex = _string.distance(from: _string.startIndex, to: utf16Index)
    // convert back
    let target = _string.index(_string.startIndex, offsetBy: charIndex)
    return _string.utf16.distance(from: _string.utf16.startIndex, to: target)
  }

  override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    _ context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
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
      let segmentFrame =
        segmentFrame.offsetBy(dx: originCorrection.x, dy: originCorrection.y)
      return block(nil, segmentFrame, baselinePosition)
    }
    // enumerate
    return context.enumerateTextSegments(
      layouRange, type: type, options: options, using: newBlock(_:_:_:))
  }

  override final func resolveTextLocation(
    with point: CGPoint, _ context: LayoutContext, _ trace: inout Trace
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

  // MARK: - Styles

  public override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    // inherit from parent
    parent?.getProperties(styleSheet) ?? [:]
  }

  // MARK: - Clone and Visitor

  override public func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(text: self, context)
  }

  // MARK: - TextNode Specific

  final var u16length: Int { _string.u16length }
  final var string: BigString { _string }

  func inserted<S>(_ string: S, at offset: Int) -> TextNode
  where S: Collection, S.Element == Character {
    let result = StringUtils.splice(_string, offset, string)
    return TextNode(result)
  }

  func removedSubrange(_ range: Range<Int>) -> TextNode {
    precondition(range.lowerBound >= 0 && range.upperBound <= u16length)
    precondition(range != 0..<u16length)
    var str = _string
    let first = str.utf16.index(str.startIndex, offsetBy: range.lowerBound)
    let last = str.utf16.index(str.startIndex, offsetBy: range.upperBound)
    str.removeSubrange(first..<last)
    return TextNode(str)
  }

  func strictSplit(at offset: Int) -> (TextNode, TextNode) {
    precondition(offset > 0 && offset < u16length)

    let (lhs, rhs) = StringUtils.strictSplit(_string, at: offset)
    return (TextNode(lhs), TextNode(rhs))
  }

  func getSlice(for range: Range<Int>) -> TextNode {
    precondition(!range.isEmpty)
    let substring = StringUtils.substring(of: _string, for: range)
    return TextNode(substring)
  }

  final func attributedSubstring(
    for range: Range<Int>, _ styleSheet: StyleSheet
  ) -> NSAttributedString {
    let substring = StringUtils.substring(of: _string, for: range)
    let properties: TextProperty = resolvePropertyAggregate(styleSheet)
    let attributes = properties.getAttributes()
    return NSAttributedString(string: String(substring), attributes: attributes)
  }
}
