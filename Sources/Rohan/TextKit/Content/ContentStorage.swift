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
        from textLocation: (any TextLocation)?,
        /* (node) -> continue */
        using block: (Node) -> Bool
    ) -> (any TextLocation)? {
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
    ) -> (any TextLocation)? {
        preconditionFailure()
    }

    // MARK: - Location

    public var documentRange: RhTextRange {
        let location = RohanTextLocation(path: [.arrayIndex(0)])
        let end = RohanTextLocation(path: [.arrayIndex(rootNode.childCount())])
        return RhTextRange(location: location, end: end)!
    }

    public func location(_ location: any TextLocation,
                         offsetBy offset: Int) -> (any TextLocation)?
    {
        guard offset != 0 else { return location }
        let location = location as! RohanTextLocation

        // convert to offset
        let n = rootNode.offset(for: location.extendedPath) + offset
        return _getLocation(n)
    }

    private func _getLocation(_ offset: Int) -> (any TextLocation)? {
        guard offset >= 0, offset <= rootNode.length else { return nil }
        let (path, offset) = rootNode.locate(offset)
        return RohanTextLocation(path: path, offset: offset)
    }

    public func offset(from: any TextLocation, to: any TextLocation) -> Int {
        let from = from as! RohanTextLocation
        let to = to as! RohanTextLocation

        let fromOffset = rootNode.offset(for: from.extendedPath)
        let toOffset = rootNode.offset(for: to.extendedPath)
        return toOffset - fromOffset
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
