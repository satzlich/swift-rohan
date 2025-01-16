// Copyright 2024-2025 Lie Yan

import Foundation
import RohanCommon

public class RhTextContentStorage {
    internal var nsTextContentStorage: NSTextContentStorage_fix
    public private(set) var textLayoutManager: RhTextLayoutManager?

    public var documentRange: RhTextRange { preconditionFailure() }

    public init() {
        self.nsTextContentStorage = .init()
    }

    public func setTextLayoutManager(_ textLayoutManager: RhTextLayoutManager?) {
        if let textLayoutManager = textLayoutManager {
            _setTextLayoutManager(textLayoutManager)
        }
        else {
            _unsetTextLayoutManager()
        }
    }

    internal func _setTextLayoutManager(_ textLayoutManager: RhTextLayoutManager) {
        if let oldLayoutManager = self.textLayoutManager {
            if oldLayoutManager === textLayoutManager { return }
            _unsetTextLayoutManager()
        }
        assert(nsTextContentStorage.textLayoutManagers.isEmpty)
        // set text layout manager
        self.textLayoutManager = textLayoutManager
        nsTextContentStorage.addTextLayoutManager(textLayoutManager.nsTextLayoutManager)
        // symmetric setting
        self.textLayoutManager!.setTextContentStorage(self)
    }

    internal func _unsetTextLayoutManager() {
        guard textLayoutManager != nil else { return }
        assert(nsTextContentStorage.textLayoutManagers.count == 1)
        // unset text layout manager
        defer { textLayoutManager = nil }
        nsTextContentStorage.removeTextLayoutManager(textLayoutManager!.nsTextLayoutManager)
        // symmetric setting
        textLayoutManager!.setTextContentStorage(nil)
    }

    public func location(_ location: any RhTextLocation,
                         offsetBy offset: Int) -> (any RhTextLocation)?
    {
        preconditionFailure()
    }

    public func offset(from: any RhTextLocation, to: any RhTextLocation) -> Int {
        preconditionFailure()
    }

    /**
     Enumerate nodes from `textLocation`.

     Closure `block` should return `false` to stop enumeration.
     ```swift
     func block(node: Node) -> Bool
     ```
     */
    internal func enumerateNodes(
        from textLocation: (any RhTextLocation)?,
        using block: (Node) -> Bool
    ) -> (any RhTextLocation)? {
        preconditionFailure()
    }

    /**
     Enumerate subnodes in `range`.

     Closure `block` should return `false` to stop enumeration.
     ```swift
     func block(
        subnode: Node?,
        subnodeRange: RhTextRange
     ) -> Bool
     ```
     */
    internal func enumerateSubnodes(
        in range: RhTextRange,
        using block: (Node?, RhTextRange) -> Bool
    ) -> (any RhTextLocation)? {
        preconditionFailure()
    }

    internal func replaceContents(in range: RhTextRange, with expressions: [Node]?) {
        preconditionFailure()
    }
}
