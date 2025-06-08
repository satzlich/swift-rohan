// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

public final class TextNode: Node {
  override class var type: NodeType { .text }

  private let _string: RhString

  public convenience init<S: Sequence<Character>>(_ string: S) {
    self.init(RhString(string))
  }

  private init(_ string: RhString) {
    precondition(!string.isEmpty && Self.validate(string: string))
    self._string = string
    super.init()
  }

  internal init(deepCopyOf textNode: TextNode) {
    self._string = textNode._string
    super.init()
  }

  static func validate<S: Sequence<Character>>(string: S) -> Bool {
    TextExpr.validate(string: string)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case string }

  public required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let string = try container.decode(RhString.self, forKey: .string)
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

  // MARK: - Location

  /// Move offset by n __characters__
  /// - Returns: nil if the destination offset is out of bounds. Otherwise, the
  ///     destination offset.
  final func destinationOffset(for offset: Int, cOffsetBy n: Int) -> Int? {
    precondition(0..._string.length ~= offset)
    // convert to string index
    let index = _string.utf16.index(_string.utf16.startIndex, offsetBy: offset)
    // move
    let target =
      n >= 0
      ? _string.index(index, offsetBy: n, limitedBy: _string.endIndex)
      : _string.index(index, offsetBy: n, limitedBy: _string.startIndex)
    guard let target else { return nil }
    // convert back
    return _string.utf16.distance(from: _string.utf16.startIndex, to: target)
  }

  override func firstIndex() -> RohanIndex? { .index(0) }

  override func lastIndex() -> RohanIndex? { .index(length) }

  // MARK: - Layout

  // Semantically layout length and string length are not the same.
  // By our design choice, their values coincide.
  override final func layoutLength() -> Int { _string.utf16.count }

  override final var isBlock: Bool { false }

  override final var isDirty: Bool { false }

  override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
    context.insertText(_string, self)
  }

  override final func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let offset = index.index(),
      0...layoutLength() ~= offset  // inclusive
    else { return nil }
    return offset
  }

  override final func getRohanIndex(_ layoutOffset: Int) -> (RohanIndex, consumed: Int)? {
    guard 0..<layoutLength() ~= layoutOffset else { return nil }
    let index = _getUpstreamBoundary(layoutOffset)
    return (.index(index), index)
  }

  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    guard 0...layoutLength() ~= layoutOffset else {
      return .failure(error: SatzError(.InvalidLayoutOffset))
    }
    let index = _getUpstreamBoundary(layoutOffset)
    return .terminal(value: .index(index), target: index)
  }

  /// Returns the index of the character at the given layout offset.
  /// - Note: ``getIndex(_:)`` differs from ``getRohanIndex(_:)`` in that the
  ///     former considers the case of `layoutOffset == layoutLength` as valid
  ///     while the latter does not.
  final func getIndex(_ layoutOffset: Int) -> Int? {
    guard 0...layoutLength() ~= layoutOffset else { return nil }
    return _getUpstreamBoundary(layoutOffset)
  }

  /// Returns the upstream boundary of the given layout offset. If the layout
  /// offset is already an upstream boundary, it returns the same value.
  private final func _getUpstreamBoundary(_ layoutOffset: Int) -> Int {
    precondition(0..._string.utf16.count ~= layoutOffset)
    let index = _string.utf16.index(_string.utf16.startIndex, offsetBy: layoutOffset)
    let target = _string.index(roundingDown: index)
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
      let offset = self.getLayoutOffset(path.first!),
      let endOffset = self.getLayoutOffset(endPath.first!)
    else { return false }

    // compute layout range
    let layouRange = (layoutOffset + offset)..<(layoutOffset + endOffset)

    // create new block
    func newBlock(
      _ layoutRange: Range<Int>?, _ segmentFrame: CGRect, _ baselinePosition: CGFloat
    ) -> Bool {
      return block(nil, segmentFrame.offsetBy(originCorrection), baselinePosition)
    }

    // enumerate
    return context.enumerateTextSegments(
      layouRange, type: type, options: options, using: newBlock(_:_:_:))
  }

  override final func resolveTextLocation(
    with point: CGPoint, _ context: LayoutContext,
    _ trace: inout Trace, _ affinity: inout RhTextSelection.Affinity
  ) -> Bool {
    // do nothing
    return false
  }

  override func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction,
    context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    guard path.count == 1,
      let localOffset = self.getLayoutOffset(path.first!)
    else { return nil }
    // perform rayshooting
    let newOffset = layoutOffset + localOffset
    guard
      let result = context.rayshoot(
        from: newOffset, affinity: affinity, direction: direction)
    else {
      return nil
    }
    return LayoutUtils.rayshootFurther(newOffset, affinity, direction, result, context)
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

  override class var storageTags: [String] {
    // intentionally empty
    []
  }

  override func store() -> JSONValue {
    .string(String(_string))
  }

  class func loadSelf(from json: JSONValue) -> _LoadResult<TextNode> {
    guard case let .string(string) = json,
      Self.validate(string: string)
    else { return .failure(UnknownNode(json)) }
    return .success(TextNode(string))
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }

  // MARK: - TextNode Specific

  final var length: Int { _string.length }
  final var string: RhString { _string }

  func inserted<S>(_ string: S, at offset: Int) -> TextNode
  where S: Collection, S.Element == Character {
    let result = StringUtils.splice(_string, offset, string)
    return TextNode(result)
  }

  func removedSubrange(_ range: Range<Int>) -> TextNode {
    precondition(range.lowerBound >= 0 && range.upperBound <= length)
    precondition(range != 0..<length)
    var str = _string
    let first = str.utf16.index(str.startIndex, offsetBy: range.lowerBound)
    let last = str.utf16.index(str.startIndex, offsetBy: range.upperBound)
    str.removeSubrange(first..<last)
    return TextNode(str)
  }

  func strictSplit(at offset: Int) -> (TextNode, TextNode) {
    precondition(offset > 0 && offset < length)

    let (lhs, rhs) = StringUtils.strictSplit(_string, at: offset)
    return (TextNode(lhs), TextNode(rhs))
  }

  func getSlice(for range: Range<Int>) -> TextNode {
    precondition(!range.isEmpty)
    let substring = StringUtils.substring(of: _string, for: range)
    return TextNode(substring)
  }

  /// Returns a substring before the given offset with at most the given
  /// character count.
  final func substring(before offset: Int, charCount: Int) -> String? {
    precondition(charCount >= 0)

    if charCount == 0 { return "" }

    let string = _string.utf16

    guard 0...string.count ~= offset else { return nil }

    let end = string.index(string.startIndex, offsetBy: offset)
    let start =
      string.index(end, offsetBy: -charCount, limitedBy: string.startIndex)
      ?? string.startIndex

    return String(_string[start..<end])
  }

  func substring(for range: Range<Int>) -> RhSubstring {
    let substring = StringUtils.substring(of: _string, for: range)
    return substring
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
