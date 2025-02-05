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
        // TODO: implement
        guard let nodes else { return }
        rootNode.insertChildren(contentsOf: nodes, at: rootNode.childCount())
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
        .init(location: RohanTextLocation([]))
    }

    public func location(_ location: any TextLocation,
                         offsetBy offset: Int) -> (any TextLocation)?
    {
        preconditionFailure()
    }

    public func offset(from: any TextLocation, to: any TextLocation) -> Int {
        preconditionFailure()
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
