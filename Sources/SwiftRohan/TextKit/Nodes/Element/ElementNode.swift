// Copyright 2024-2025 Lie Yan

import Algorithms
import BitCollections
import CoreGraphics
import DequeModule
import _RopeModule

/// Storage for `ElementNode` children.
internal typealias ElementStore = Deque<Node>

internal class ElementNode: Node {
  // MARK: - Node

  final override func resetCachedProperties() {
    super.resetCachedProperties()
    for child in _children {
      child.resetCachedProperties()
    }
  }

  // MARK: - Node(Positioning)

  final override func getChild(_ index: RohanIndex) -> Node? {
    guard let index = index.index(),
      index < _children.count
    else { return nil }
    return _children[index]
  }

  final override func firstIndex() -> RohanIndex? { .index(0) }

  final override func lastIndex() -> RohanIndex? { .index(_children.count) }

  internal override func getLayoutOffset(_ index: RohanIndex) -> Int? {
    preconditionFailure("overriding required")
  }

  internal override func getPosition(_ layoutOffset: Int) -> PositionResult<RohanIndex> {
    preconditionFailure("overriding required")
  }

  // MARK: - Node(Layout)

  final override func contentDidChange() {
    guard _isDirty == false else { return }
    _isDirty = true
    parent?.contentDidChange()
  }

  final override func layoutLength() -> Int { _layoutLength }

  final override var isBlock: Bool { NodePolicy.isBlockElement(type) }
  final override var isDirty: Bool { _isDirty }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case children }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var childrenContainer = try container.nestedUnkeyedContainer(forKey: .children)

    // children and newlines
    self._children = try NodeSerdeUtils.decodeListOfNodes(from: &childrenContainer)
    self._newlines = NewlineArray(_children.lazy.map(\.isBlock))

    self._layoutLength = 0
    self._isDirty = false

    try super.init(from: decoder)
    self._setUp()
  }

  internal override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self._children, forKey: .children)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Tree API)

  private static let _maxPathLength = 3  // heuristic limit for cursor correction.

  /// Returns the node that needs leading cursor correction.
  private final func _leadingCursorCorrectionNode(_ path: ArraySlice<RohanIndex>) -> Node?
  {
    guard path.count <= Self._maxPathLength,
      let trace = Trace.from(path, self),
      let last = trace.last,
      let descendant = last.getChild(),
      descendant.needsLeadingCursorCorrection
    else { return nil }
    return descendant
  }

  /// Returns the node that needs trailing cursor correction.
  @inline(__always)
  private final func _trailingCursorCorrectionNode(
    _ path: ArraySlice<RohanIndex>
  ) -> Node? {
    guard path.count <= Self._maxPathLength,
      let trace = Trace.from(path, self),
      let last = trace.last,
      let lastIndex = last.index.index(),
      lastIndex > 0,
      let previous = last.node.getChild(.index(lastIndex - 1)),
      previous.needsTrailingCursorCorrection,
      // when `previous` is the last child.
      last.getChild() == nil
    else { return nil }
    return previous
  }

  final override func enumerateTextSegments(
    _ path: ArraySlice<RohanIndex>, _ endPath: ArraySlice<RohanIndex>,
    context: any LayoutContext, layoutOffset: Int, originCorrection: CGPoint,
    type: DocumentManager.SegmentType, options: DocumentManager.SegmentOptions,
    using block: DocumentManager.EnumerateTextSegmentsBlock
  ) -> Bool {

    guard let index = path.first?.index(),
      let endIndex = endPath.first?.index()
    else { assertionFailure("Invalid path"); return false }

    if self.isPlaceholderActive {
      assert(path.count == 1 && endPath.count == 1)
      assert(index == endIndex && index == 0)
      let layoutRange = layoutOffset..<layoutOffset + 1

      func placeholderBlock(
        _ range: Range<Int>?, _ segmentFrame: CGRect, _ baselinePosition: CGFloat
      ) -> Bool {
        var correctedFrame = segmentFrame.offsetBy(originCorrection)
        correctedFrame.origin.x = correctedFrame.midX
        correctedFrame.size.width = 0
        return block(nil, correctedFrame, baselinePosition)
      }
      return context.enumerateTextSegments(
        layoutRange, type: type, options: options, using: placeholderBlock(_:_:_:))
    }
    else if path.count == 1 || endPath.count == 1 || index != endIndex {
      guard let offset = TreeUtils.computeLayoutOffset(for: path, self),
        let endOffset = TreeUtils.computeLayoutOffset(for: endPath, self)
      else { assertionFailure("Invalid path"); return false }
      let layoutRange = layoutOffset + offset..<layoutOffset + endOffset

      let firstNode: Node? = _leadingCursorCorrectionNode(path)
      let lastNode: Node? = _trailingCursorCorrectionNode(endPath)

      func specialBlock(
        _ firstNode: Node?, _ lastNode: Node?,
        _ range: Range<Int>?, _ segmentFrame: CGRect, _ baselinePosition: CGFloat
      ) -> Bool {
        var correctedFrame = segmentFrame.offsetBy(originCorrection)
        // apply leading correction
        if let firstNode = firstNode,
          range?.lowerBound == layoutRange.lowerBound
        {
          let cursorCorrection = firstNode.leadingCursorCorrection()
          correctedFrame.origin.x += cursorCorrection
          if correctedFrame.size.width != 0 {
            correctedFrame.size.width -= cursorCorrection
          }
        }
        // apply trailing correction
        if let lastNode = lastNode,
          range?.upperBound == layoutRange.upperBound,
          let trailingCursorPos = lastNode.trailingCursorPosition()
        {
          if correctedFrame.size.width == 0 {
            correctedFrame.origin.x = trailingCursorPos
          }
          else {
            let extender = max(trailingCursorPos - correctedFrame.maxX, 0)
            correctedFrame.size.width += extender
          }
        }
        return block(nil, correctedFrame, baselinePosition)
      }

      return context.enumerateTextSegments(
        layoutRange, type: type, options: options,
        using: { specialBlock(firstNode, lastNode, $0, $1, $2) })
    }
    // ASSERT: path.count > 1 && endPath.count > 1 && index == endIndex
    else {  // if paths don't branch, recurse
      guard index < self.childCount,
        let offset = getLayoutOffset(index)
      else { assertionFailure("Invalid path"); return false }
      return _children[index].enumerateTextSegments(
        path.dropFirst(), endPath.dropFirst(), context: context,
        layoutOffset: layoutOffset + offset, originCorrection: originCorrection,
        type: type, options: options, using: block)
    }
  }

  final override func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity
  ) -> Bool {
    guard let result = context.getLayoutRange(interactingAt: point) else { return false }

    let pickedRange = PickedRange(result.layoutRange, result.fraction)
    affinity = result.affinity

    return resolveTextLocation(
      with: point, context: context, layoutOffset: layoutOffset,
      trace: &trace, affinity: &affinity, pickedRange: pickedRange)
  }

  /// Resolve the text location at the given point and layout range.
  /// - Parameters:
  ///   - point: the point relative to the layout context, relative to the
  ///       **top-left corner** of the context. For TextKit, it's relative to
  ///       the **top-left corner** of the container. For MathListLayoutContext,
  ///       it's relative to the **top-left corner** of the math list, which is
  ///       usually different from the glyph origin.
  ///   - context: the layout context
  ///   - layoutOffset: the layout offset of this node in the layout context.
  ///   - trace: the trace to append the resolved location to.
  ///   - affinity: the selection affinity to resolve.
  /// - Returns: true if trace is modified.
  final func resolveTextLocation(
    with point: CGPoint, context: any LayoutContext, layoutOffset: Int,
    trace: inout Trace, affinity: inout SelectionAffinity,
    pickedRange: PickedRange
  ) -> Bool {
    if pickedRange.isEmpty {
      let localOffset = pickedRange.lowerBound
      guard localOffset <= _layoutLength else {
        trace.emplaceBack(self, .index(self.childCount))
        return true
      }
      let result = Trace.getTraceSegment(localOffset, self)

      switch result {
      case .terminal(let value, _):
        trace.append(contentsOf: value)
        return true

      case .halfway(let value, let consumed):
        assert(value.isEmpty == false)
        trace.append(contentsOf: value)

        // if the tip is ApplyNode, recurse into it.
        if let child = trace.last?.getChild(),
          let applyNode = child as? ApplyNode
        {
          // The content of ApplyNode is treated as being expanded in-place.
          // So keep the original point.
          if let newPickedRange = pickedRange.subtracting(consumed) {
            _ = applyNode.resolveTextLocation(
              with: point, context: context,
              layoutOffset: layoutOffset + consumed,
              trace: &trace, affinity: &affinity,
              pickedRange: newPickedRange)
          }
          else {
            assertionFailure("subtraction of consumed from pickedRange failed")
          }
          return true
        }
        else {
          return true
        }

      case .null:
        return false
      case .failure:
        return false
      }
    }
    else {
      let localOffset = pickedRange.lowerBound

      /// compute fraction from upstream of child.
      /// - Parameter startOffset: the offset of the child relative to the start
      ///     of this node.
      func computeFraction(_ startOffset: Int, _ child: Node) -> Double {
        let lowerBound = Double(localOffset - startOffset)
        let location = Double(pickedRange.count) * pickedRange.fraction + lowerBound
        let fraction = location / Double(child.layoutLength())
        return fraction
      }

      let result = Trace.getTraceSegment(localOffset, self)
      switch result {
      case .terminal(let value, let target):
        assert(value.isEmpty == false)
        guard let last = value.last else { return false }

        switch last.node {
        case _ as TextNode:
          trace.append(contentsOf: value)
          let fraction = pickedRange.fraction
          let resolved = last.index.index()! + (fraction > 0.5 ? pickedRange.count : 0)
          trace.moveTo(.index(resolved))
          return true

        case let node as ElementNode:
          let index = last.index.index()!
          if index == node.childCount {
            trace.append(contentsOf: value)
            return true
          }
          else {
            let child = node.getChild(index)
            if isSimpleNode(child) {
              trace.append(contentsOf: value)
              let fraction = computeFraction(target, child)
              let resolved = index + (fraction > 0.5 ? 1 : 0)
              trace.moveTo(.index(resolved))
              return true
            }
            else {
              trace.append(contentsOf: value)
              return true
            }
          }

        default:
          assertionFailure("unexpected node type: \(Swift.type(of: last.node))")
          return false
        }

      case .halfway(let value, let consumed):
        assert(value.isEmpty == false)
        guard let last = value.last,
          let child = last.getChild(),
          let index = last.index.index()
        else { return false }
        assert(child.isPivotal)

        func fallbackLastIndex() {
          let fraction = computeFraction(consumed, child)
          if fraction > 0.5 {
            trace.moveTo(.index(index + 1))
            affinity = .upstream
          }
          else {
            trace.moveTo(.index(index))
            affinity = .downstream
          }
        }

        switch child {
        case let node as GenMathNode:
          trace.append(contentsOf: value)
          let modified = node.resolveTextLocation(
            with: point, context: context, layoutOffset: layoutOffset + consumed,
            trace: &trace, affinity: &affinity)
          if !modified { fallbackLastIndex() }
          return true

        case let applyNode as ApplyNode:
          // content of ApplyNode is effectively expanded in-place. Thus we recurse
          // with the original point and subtract consumed from the layout range.
          trace.append(contentsOf: value)
          if let newPickedRange = pickedRange.subtracting(consumed) {
            let modified = applyNode.resolveTextLocation(
              with: point, context: context, layoutOffset: layoutOffset + consumed,
              trace: &trace, affinity: &affinity,
              pickedRange: newPickedRange)
            if !modified { fallbackLastIndex() }
          }
          else {
            assertionFailure("subtraction of consumed from pickedRange failed")
            fallbackLastIndex()
          }
          return true

        default:
          assertionFailure("unexpected node type: \(Swift.type(of: child))")
          fallbackLastIndex()
          return true
        }
      case .null:
        return false
      case .failure:
        return false
      }
    }
  }

  final override func rayshoot(
    from path: ArraySlice<RohanIndex>,
    affinity: SelectionAffinity,
    direction: TextSelectionNavigation.Direction,
    context: LayoutContext, layoutOffset: Int
  ) -> RayshootResult? {
    guard let index = path.first?.index(),
      let localOffset = getLayoutOffset(index)
    else { return nil }

    if path.count == 1 {
      assert(index <= self.childCount)
      let newOffset = layoutOffset + localOffset
      guard
        var result =
          context.rayshoot(from: newOffset, affinity: affinity, direction: direction)
      else {
        return nil
      }

      // apply horizontal shift for placeholder.
      if isPlaceholderActive {
        assert(localOffset == 0)
        if let segmentFrame = context.getSegmentFrame(layoutOffset + 1, .upstream) {
          result.position.x = (result.position.x + segmentFrame.frame.origin.x) / 2
        }
      }
      else if let leadingNode = _leadingCursorCorrectionNode(path) {
        result.position.x += leadingNode.leadingCursorCorrection()
      }
      else if let trailingNode = _trailingCursorCorrectionNode(path),
        let x = trailingNode.trailingCursorPosition()
      {
        result.position.x = x
      }

      return LayoutUtils.relayRayshoot(
        newOffset, affinity, direction, result, context)
    }
    else {
      guard index < self.childCount else { return nil }
      return _children[index].rayshoot(
        from: path.dropFirst(), affinity: affinity,
        direction: direction, context: context,
        layoutOffset: layoutOffset + localOffset)
    }
  }

  // MARK: - ElementNode

  /// Visit the children in the manner of this node.
  internal func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    preconditionFailure("overriding required")
  }

  /// Create a node for splitting at the end.
  internal func createSuccessor() -> ElementNode? { nil }  // default to nil.

  /// Create an empty clone of this node.
  internal func cloneEmpty() -> Self { preconditionFailure("overriding required") }

  /// Encode this node but with children replaced with given children.
  ///
  /// Helper function for encoding partial nodes. Override this method to encode
  /// extra properties.
  internal func encode<S: Collection<PartialNode> & Encodable>(
    to encoder: any Encoder, withChildren children: S
  ) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(children, forKey: .children)
    try super.encode(to: encoder)
  }

  // MARK: - Implementation

  internal final var _children: ElementStore

  /// layout length contributed by the node.
  internal final var _layoutLength: Int

  /// true if a newline should be added after i-th child.
  internal final var _newlines: NewlineArray

  internal final var _isDirty: Bool

  internal final var _counterSegment: CounterSegment?

  final override var counterSegment: CounterSegment? { _counterSegment }

  /// - Warning: Sync with other init() method.
  internal init(_ children: ElementStore) {
    self._children = children
    self._newlines = NewlineArray(children.lazy.map(\.isBlock))
    self._layoutLength = 0
    self._isDirty = false

    super.init()
    self._setUp()
  }

  /// - Warning: Sync with other init() method.
  internal override init() {
    self._children = ElementStore()
    self._newlines = NewlineArray()
    self._layoutLength = 0
    self._isDirty = false

    super.init()
    self._setUp()
  }

  /// - Warning: Sync with other init() method.
  internal init(deepCopyOf elementNode: ElementNode) {
    self._children = ElementStore(elementNode._children.lazy.map { $0.deepCopy() })
    self._newlines = elementNode._newlines
    self._layoutLength = elementNode._layoutLength
    self._isDirty = false

    super.init()
    self._setUp()
  }

  private final func _setUp() {
    for child in _children {
      child.setParent(self)
    }
  }

  // MARK: - Layout Impl.

  /// true if placeholder should be shown when the node is empty.
  final var isPlaceholderEnabled: Bool { NodePolicy.isPlaceholderEnabled(type) }

  /// true if placeholder should be shown.
  final var isPlaceholderActive: Bool { isPlaceholderEnabled && _children.isEmpty }

  /// Make snapshot once if not already made
  /// - Note: Call to method `performLayout(_:fromScratch:)` will clear the snapshot.
  internal func makeSnapshotOnce() { preconditionFailure("overriding required") }

  internal func snapshotDescription() -> Array<String>? {
    preconditionFailure("overriding required")
  }

  internal func getLayoutOffset(_ index: Int) -> Int? {
    preconditionFailure("overriding required")
  }

  // MARK: - Children

  final var childCount: Int { _children.count }

  final func getChild(_ index: Int) -> Node { _children[index] }

  /// Take all children from the node.
  final func takeChildren(inStorage: Bool) -> ElementStore {
    if inStorage { makeSnapshotOnce() }

    for child in _children {
      child.clearParent()
    }
    let children = exchange(&_children, with: [])
    _newlines.removeAll()

    if inStorage { contentDidChange() }
    return children
  }

  final func takeSubrange(_ range: Range<Int>, inStorage: Bool) -> ElementStore {
    if 0..<childCount == range { return takeChildren(inStorage: inStorage) }

    if inStorage { makeSnapshotOnce() }

    for child in _children[range] {
      child.clearParent()
    }
    let children = ElementStore(_children[range])
    _children.removeSubrange(range)
    _newlines.removeSubrange(range)

    if inStorage { contentDidChange() }
    return children
  }

  final func insertChild(_ node: Node, at index: Int, inStorage: Bool) {
    insertChildren(contentsOf: CollectionOfOne(node), at: index, inStorage: inStorage)
  }

  final func insertChildren<S: Collection<Node>>(
    contentsOf nodes: S, at index: Int, inStorage: Bool
  ) {
    guard !nodes.isEmpty else { return }

    if inStorage { makeSnapshotOnce() }

    _children.insert(contentsOf: nodes, at: index)
    _newlines.insert(contentsOf: nodes.lazy.map(\.isBlock), at: index)

    for node in nodes {
      node.setParent(self)
    }

    if inStorage { contentDidChange() }
  }

  final func removeChild(at index: Int, inStorage: Bool) {
    removeSubrange(index..<index + 1, inStorage: inStorage)
  }

  final func removeSubrange(_ range: Range<Int>, inStorage: Bool) {
    if inStorage { makeSnapshotOnce() }

    for child in _children[range] {
      child.clearParent()
    }
    _children.removeSubrange(range)
    _newlines.removeSubrange(range)

    if inStorage { contentDidChange() }
  }

  internal final func replaceChild(_ node: Node, at index: Int, inStorage: Bool) {
    precondition(_children[index] !== node && node.parent == nil)

    if inStorage { makeSnapshotOnce() }

    _children[index].clearParent()
    _children[index] = node
    _children[index].setParent(self)
    _newlines.setValue(isBlock: node.isBlock, at: index)

    if inStorage { contentDidChange() }
  }
}

extension ElementNode {
  /// Returns the children of this node for read-only access.
  final func childrenReadonly() -> ElementStore { _children }

  /// Returns true if node is allowed to be empty.
  final var isVoidable: Bool { NodePolicy.isVoidableElement(type) }

  /// Returns true if the node is mergeable with another element node.
  final func isMergeable(with other: ElementNode) -> Bool {
    NodePolicy.isMergeableElements(self.type, other.type)
  }
}
