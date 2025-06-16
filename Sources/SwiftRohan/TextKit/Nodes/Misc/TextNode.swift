// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class TextNode: Node {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(text: self, context)
  }

  final override class var type: NodeType { .text }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    // Use the properties from the parent node if available.
    parent?.getProperties(styleSheet) ?? [:]
  }

  final override func getChild(_ index: RohanIndex) -> Node? { nil }

  final override func firstIndex() -> RohanIndex? { .index(0) }
  final override func lastIndex() -> RohanIndex? { .index(_string.length) }

  // MARK: - Node(Layout)

  final override func layoutLength() -> Int { _string.length }

  final override var isDirty: Bool { false }

  final override func performLayout(_ context: LayoutContext, fromScratch: Bool) -> Int {
    if fromScratch {
      context.insertText(_string, self)
    }
    else {
      assertionFailure("TextNode should not be laid out incrementally.")
    }
    return layoutLength()
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case string }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let string = try container.decode(BigString.self, forKey: .string)
    guard Self.validate(string: string) else {
      throw DecodingError.dataCorruptedError(
        forKey: .string, in: container, debugDescription: "Invalid text string.")
    }
    self._string = string

    try super.init(from: decoder)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_string, forKey: .string)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> { /* intentionally empty */ [] }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    loadSelf(from: json).cast()
  }

  final override func store() -> JSONValue { .string(String(_string)) }

  // MARK: - Node(Tree API)

  final override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
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

  final override func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity
  ) -> Bool {
    // no-op
    return false
  }

  final override func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: SelectionAffinity,
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
    else { return nil }
    return LayoutUtils.relayRayshoot(newOffset, affinity, direction, result, context)
  }

  // MARK: - Storage

  final class func loadSelf(from json: JSONValue) -> NodeLoaded<TextNode> {
    guard case let .string(string) = json,
      Self.validate(string: string)
    else { return .failure(UnknownNode(json)) }
    return .success(TextNode(string))
  }

  // MARK: - TextNode

  private let _string: BigString

  public convenience init<S: Sequence<Character>>(_ string: S) {
    self.init(BigString(string))
  }

  private init(_ string: BigString) {
    precondition(!string.isEmpty && Self.validate(string: string))
    self._string = string
    super.init()
  }

  private init(deepCopyOf textNode: TextNode) {
    self._string = textNode._string
    super.init()
  }

  static func validate<S: Sequence<Character>>(string: S) -> Bool {
    TextExpr.validate(string: string)
  }

  // MARK: - Implementation

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

  final override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    guard let offset = index.index(),
      0...layoutLength() ~= offset  // inclusive
    else { return nil }
    return offset
  }

  final override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    guard 0...layoutLength() ~= layoutOffset else {
      return .failure(SatzError(.InvalidLayoutOffset))
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

  // MARK: - TextNode Specific

  final var length: Int { _string.length }
  final var string: BigString { _string }

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

  func substring(for range: Range<Int>) -> BigSubstring {
    let substring = StringUtils.substring(of: _string, for: range)
    return substring
  }

  final func attributedSubstring(
    for range: Range<Int>, _ styleSheet: StyleSheet
  ) -> NSAttributedString {
    let substring = StringUtils.substring(of: _string, for: range)
    let properties: TextProperty = resolveAggregate(styleSheet)
    let attributes = properties.getAttributes()
    return NSAttributedString(string: String(substring), attributes: attributes)
  }
}
