// Copyright 2024-2025 Lie Yan

import Foundation
import RohanCommon

public class RhTextContentStorage {
    internal var nsTextContentStorage: NSTextContentStorage_fix
    public private(set) var textLayoutManager: RhTextLayoutManager?

    internal var rootNode: RootNode

    public init() {
        self.nsTextContentStorage = .init()
        self.rootNode = RootNode()
    }

    public func replaceContents(in range: RhTextRange, with nodes: [Node]?) {
        // This is provisional.
        // TODO: implement
        guard let nodes else { return }
        rootNode.insertChildren(contentsOf: nodes, at: rootNode.childCount())
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

    // MARK: - Location

    public var documentRange: RhTextRange {
        let location = _location(padded: 0)!
        let end = _location(padded: rootNode.paddedLength)!
        return RhTextRange(location: location, end: end)!
    }

    public func location(_ location: any RhTextLocation,
                         offsetBy offset: Int) -> (any RhTextLocation)?
    {
        guard offset != 0 else { return location }
        let location = location as! RohanTextLocation

        // convert to offset
        let n = rootNode.offset(location.getFullPath()) + offset
        return _location(n, offset > 0 ? .upstream : .downstream)
    }

    internal func _location(
        _ offset: Int,
        _ affinity: SelectionAffinity
    ) -> (any RhTextLocation)? {
        guard offset >= 0, offset <= rootNode.length else { return nil }
        let (path, offset) = rootNode.locate(offset, affinity)
        return RohanTextLocation(path: path, offset: offset)
    }

    public func offset(from: any RhTextLocation, to: any RhTextLocation) -> Int {
        let from = from as! RohanTextLocation
        let to = to as! RohanTextLocation
        return rootNode.offset(to.getFullPath()) - rootNode.offset(from.getFullPath())
    }

    public func location(_ location: any RhTextLocation,
                         paddedOffsetBy offset: Int) -> (any RhTextLocation)?
    {
        guard offset != 0 else { return location }
        let location = location as! RohanTextLocation

        // convert to offset
        let n = rootNode.paddedOffset(for: location.getFullPath()) + offset
        return _location(padded: n)
    }

    internal func _location(padded offset: Int) -> (any RhTextLocation)? {
        guard offset >= 0, offset <= rootNode.paddedLength else { return nil }
        let (path, offset) = rootNode.locate(forPadded: offset)
        return RohanTextLocation(path: path, offset: offset)
    }

    public func paddedOffset(from: any RhTextLocation, to: any RhTextLocation) -> Int {
        let from = from as! RohanTextLocation
        let to = to as! RohanTextLocation
        return rootNode.paddedOffset(for: to.getFullPath()) -
            rootNode.paddedOffset(for: from.getFullPath())
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
