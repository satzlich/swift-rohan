// Copyright 2024-2025 Lie Yan

import Foundation
import RohanCommon

public class RhTextContentStorage {
    internal var nsTextContentStorage: NSTextContentStorage_fix
    public private(set) var textLayoutManager: RhTextLayoutManager?

    internal var nodeStorage: RootNode

    public var documentRange: RhTextRange {
        let location = self.location(0, preferEnd: false)!
        let end = self.location(nodeStorage.length, preferEnd: true)!
        return RhTextRange(location: location, end: end)!
    }

    public init() {
        self.nsTextContentStorage = .init()
        self.nodeStorage = RootNode()
    }

    public func location(_ location: any RhTextLocation,
                         offsetBy offset: Int) -> (any RhTextLocation)?
    {
        guard offset != 0 else { return location }
        let location = location as! RohanTextLocation

        // convert to offset
        let i = nodeStorage.offset(location.fullPath()) + offset
        return self.location(i, preferEnd: offset > 0)
    }

    internal func location(_ offset: Int, preferEnd: Bool) -> (any RhTextLocation)? {
        guard offset >= 0, offset <= nodeStorage.length else { return nil }
        let (path, offset) = nodeStorage.locate(offset, preferEnd: preferEnd)
        return RohanTextLocation(path: path, offset: offset)
    }

    public func offset(from: any RhTextLocation, to: any RhTextLocation) -> Int {
        let from = from as! RohanTextLocation
        let to = to as! RohanTextLocation
        return nodeStorage.offset(to.fullPath()) - nodeStorage.offset(from.fullPath())
    }

    public func replaceContents(in range: RhTextRange, with nodes: [Node]?) {
        // TODO: implement
        guard let nodes else { return }
        nodeStorage.insertChildren(contentsOf: nodes, at: nodeStorage.childCount())
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

    // MARK: - TextLayoutManager

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
}
