// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import RohanCommon

public class ContentStorage {
    /** companion layout manager */
    private var _layoutManager: LayoutManager?
    var layoutManager: LayoutManager? { @inline(__always) get { _layoutManager }}
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

    public func replaceContents(in range: RhTextRange, with nodes: [Node]?) {
        guard let nodes else { return }
        rootNode.insertChildren(contentsOf: nodes, at: rootNode.childCount())
    }

    /**
     Replace contents in `range` with `string`.

     - Precondition: `string` is free of newlines (except line separators)
     */
    public func replaceContents(in range: RhTextRange, with string: String) throws {
        precondition(TextNode.validate(string: string))

        if !range.isEmpty {
            // remove selected region
            fatalError("TODO: implement")
        }

        // if the string is empty, do nothing
        guard string.isEmpty == false else { return }

        let nodes = NodeUtils.traceNodes(along: range.location.path, rootNode)
        let (last, _) = nodes.last!
        /* consider three kinds of insertion point
            a) in a text node
            b) in a root node
            c) in an element node (other than root)
         */
        func isTextNode(_ node: Node) -> Bool { node.nodeType == .text }
        func isRootNode(_ node: Node) -> Bool { node.nodeType == .root }
        func isElementNode(_ node: Node) -> Bool {
            node is ElementNode && node.nodeType != .root
        }

        if isTextNode(last) {
            let textNode = last as! TextNode
            // get parent and index
            let (parent, index) = nodes.dropLast().last!
            guard let parent = parent as? ElementNode,
                  let index = index?.nodeIndex()
            else { throw SatzError(code: .InvalidTextLocation) }
            // perform insertion
            NodeUtils.insert(string, textNode: textNode, offset: range.location.offset,
                             parent, index)
        }
        else if isRootNode(last) {
            let (root, index) = (last as! RootNode, range.location.offset)
            let childCount = root.childCount()
            // if there is no existing node to insert into, create a paragraph
            if childCount == 0 {
                assert(index == 0)
                let paragraph = ParagraphNode([TextNode(string)])
                root.insertChild(paragraph, at: index, inContentStorage: true)
            }
            // if the index is the last index, add to the end of the last child
            else if index == childCount {
                assert(childCount > 0)
                guard let lastChild = root.getChild(childCount - 1) as? ElementNode
                else { throw SatzError(code: .ElementNodeExpected) }
                NodeUtils.insert(string, elementNode: lastChild,
                                 index: lastChild.childCount())
            }
            // otherwise, add to the start of index-th child
            else {
                assert(index < root.childCount())
                guard let parent = root.getChild(index) as? ElementNode
                else { throw SatzError(code: .ElementNodeExpected) }

                // cases:
                //  1) there is a text node to insert into
                //  2) we need create a new text node
                if parent.childCount() > 0,
                   let textNode = parent.getChild(0) as? TextNode
                {
                    NodeUtils.insert(string, textNode: textNode, offset: 0, parent, 0)
                }
                else {
                    parent.insertChild(TextNode(string), at: 0, inContentStorage: true)
                }
            }
        }
        else if isElementNode(last) {
            let (parent, index) = (last as! ElementNode, range.location.offset)
            NodeUtils.insert(string, elementNode: parent, index: index)
        }
        else {
            throw SatzError(code: .InvalidTextLocation, message:
                "location should points to a text node or an element node")
        }
    }

    /**
     Enumerate nodes from `textLocation`.

     Closure `block` should return `false` to stop enumeration.
     */
    internal func enumerateNodes(
        from textLocation: RohanTextLocation?,
        /* (node) -> continue */
        using block: (Node) -> Bool
    ) -> RohanTextLocation? {
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
    ) -> RohanTextLocation? {
        preconditionFailure()
    }

    // MARK: - Location

    public var documentRange: RhTextRange {
        // TODO: implement
        RhTextRange(location: RohanTextLocation([], 0))
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
        self._layoutManager = layoutManager
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
