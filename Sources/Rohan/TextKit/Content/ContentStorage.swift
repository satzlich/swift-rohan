// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import RohanCommon

public class ContentStorage {
  /** companion layout manager */
  private var _layoutManager: LayoutManager?
  var layoutManager: LayoutManager? { @inline(__always) get { _layoutManager } }
  /** base text content storage */
  private var _textContentStorage: NSTextContentStorage
  var textContentStorage: NSTextContentStorage {
    @inline(__always) get { _textContentStorage }
  }

  /** root of the document */
  internal let rootNode: RootNode

  public init() {
    self._textContentStorage = NSTextContentStoragePatched()
    self.rootNode = RootNode()
  }

  init(_ rootNode: RootNode) {
    self._textContentStorage = NSTextContentStoragePatched()
    self.rootNode = rootNode
  }

  private var _hasEditingTransaction: Bool = false
  var hasEditingTransaction: Bool { @inline(__always) get { _hasEditingTransaction } }

  public func performEditingTransaction(_ transaction: () -> Void) {
    _hasEditingTransaction = true
    transaction()
    // ensure layout in a delayed fashion
    layoutManager?.ensureLayout(delayed: true)
    _hasEditingTransaction = false
  }

  public func replaceContents(in range: RhTextRange, with nodes: [Node]?) throws {
    if !range.isEmpty {
      try removeContents(in: range)
    }
    guard let nodes else { return }
    // TODO: implement
    rootNode.insertChildren(contentsOf: nodes, at: rootNode.childCount)
  }

  /**
     Replace contents in `range` with `string`. If an exception is thrown, the
     document is left unchanged.

     - Precondition: `string` is free of newlines (except line separators `\u{2028}`)
     - Throws: SatzError(.InsaneRootChild), SatzError(.InvalidTextLocation),
        SatzError(.InvalidTextRange)
     */
  public func replaceContents(in range: RhTextRange, with string: String) throws {
    precondition(TextNode.validate(string: string))

    if !range.isEmpty {
      try removeContents(in: range)
      // ASSERT: range.location remains valid
    }

    // if the string is empty, do nothing
    guard !string.isEmpty else { return }

    guard let nodes = NodeUtils.traceNodes(range.location, rootNode),
      let lastNode = nodes.last?.node
    else { throw SatzError(.InvalidTextLocation) }

    // Consider three cases:
    //  1) text node, 2) root node, or 3) element node (other than root).
    switch lastNode {
    case let textNode as TextNode:
      let offset = range.location.offset
      // get parent and index
      // check index and offset
      guard let parent_ = nodes.dropLast().last,
        let parent = parent_.node as? ElementNode,
        let index = parent_.index.index(),
        index < parent.childCount,
        offset <= textNode.characterCount
      else { throw SatzError(.InvalidTextLocation) }
      // perform insertion
      NodeUtils.insertString(
        string,
        textNode: textNode,
        offset: offset,
        parent,
        index
      )
    case let rootNode_ as RootNode:  // "_" suffix to avoid name conflict
      let index = range.location.offset
      guard index <= rootNode_.childCount
      else { throw SatzError(.InvalidTextLocation) }
      try NodeUtils.insertString(string, rootNode: rootNode_, index: index)
    case let elementNode as ElementNode:
      let index = range.location.offset
      guard index <= elementNode.childCount
      else { throw SatzError(.InvalidTextLocation) }
      NodeUtils.insertString(string, elementNode: elementNode, index: index)
    default:
      throw SatzError(
        .InvalidTextLocation, message: "location should point into text or element node")
    }
  }

  /**
     Remove contents in `range`. If an exception is thrown, the document is left
     unchanged.

     - Postcondition: `range.location` remains valid after removing contents in `range`,
     whether or not an exception is thrown.
     - Throws: SatzError(.InvalidTextRange)
     */
  private func removeContents(in range: RhTextRange) throws {
    guard NodeUtils.validateTextRange(range, rootNode)
    else { throw SatzError(.InvalidTextRange) }

  }

  /**
     Enumerate nodes from `textLocation`.

     Closure `block` should return `false` to stop enumeration.
     */
  internal func enumerateNodes(
    from textLocation: TextLocation?,
    /* (node) -> continue */
    using block: (Node) -> Bool
  ) -> TextLocation? {
    preconditionFailure()
  }

  /**
     Enumerate subnodes in `range`.

     Closure `block` should return `false` to stop enumeration.
     */
  internal func enumerateSubnodes(
    in range: RhTextRange,
    /* (subnode, subnodeRange) -> continue */
    using block: (Node?, RhTextRange) -> Bool
  ) -> TextLocation? {
    preconditionFailure()
  }

  // MARK: - Location

  public var documentRange: RhTextRange {
    let location = TextLocation([], 0)
    let endLocation = TextLocation([], rootNode.childCount)
    return RhTextRange(location, endLocation)!
  }

  // MARK: - LayoutManager

  public func setLayoutManager(_ layoutManager: LayoutManager?) {
    if layoutManager != nil {
      _setLayoutManager(layoutManager!)
    }
    else {
      _unsetLayoutManager()
    }
  }

  private func _setLayoutManager(_ layoutManager: LayoutManager) {
    // if there is already a layout manager, unset the old
    if self.layoutManager != nil { _unsetLayoutManager() }

    // set layout manager
    _layoutManager = layoutManager
    // set text layout manager
    assert(_textContentStorage.textLayoutManagers.isEmpty)
    _textContentStorage.addTextLayoutManager(layoutManager.textLayoutManager)
    _textContentStorage.primaryTextLayoutManager = layoutManager.textLayoutManager
    // modify layout manager symmetrically
    self.layoutManager!.setContentStorage(self)
  }

  private func _unsetLayoutManager() {
    // ensure layout manager is set
    guard layoutManager != nil else { return }

    // unset text layout manager
    assert(_textContentStorage.textLayoutManagers.count == 1)
    _textContentStorage.removeTextLayoutManager(layoutManager!.textLayoutManager)
    // modify layout manager symmetrically
    layoutManager!.setContentStorage(nil)
    // unset layout manager
    _layoutManager = nil
  }
}
