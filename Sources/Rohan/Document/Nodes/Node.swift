// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

/**
 Persistent node
 */
class Node {
    // propreties

    class var type: NodeType {
        .unknown
    }

    public final var type: NodeType {
        Self.type
    }

    // relations

    final weak var _parent: Node? // unversioned
    final var parent: Node? { _parent }

    // versions

    /** latest version of the node */
    public private(set) final var nodeVersion: VersionId
    /** the versions where descendants changed at */
    private final var _nestedChangeVersions: VersionIdArray

    /** max lastest version of the descendents */
    public final var maxNestedVersion: VersionId {
        _nestedChangeVersions.last ?? VersionId.defaultInitial
    }

    /** the latest version of the subtree */
    public final var subtreeVersion: VersionId {
        Swift.max(nodeVersion, maxNestedVersion)
    }

    // editing status

    private final var _editingLevel: Int = 0
    final var isEditing: Bool {
        _editingLevel > 0
    }

    public init(_ version: VersionId = .defaultInitial) {
        self.nodeVersion = version
        self._nestedChangeVersions = .init()
    }

    /**
     Returns a copy of this node with the current version to default initial version
     */
    public func clone() -> Node {
        preconditionFailure()
    }

    /**
     Returns the length of the range occupied by this node for `version`.
     */
    public func rangeLength(for version: VersionId) -> Int {
        preconditionFailure()
    }

    public final func rangeLength() -> Int {
        rangeLength(for: subtreeVersion)
    }

    // MARK: - Versions

    /**
     Returns true if any descendants are locally changed at `version`.
     */
    public final func nestedChanged(_ version: VersionId) -> Bool {
        precondition(!isEditing)
        return _nestedChangeVersions.contains(version)
    }

    /**
     Returns true if this node is locally changed at `version`.
     */
    public func localChanged(_ version: VersionId) -> Bool {
        false
    }

    public final func nestedChanged() -> Bool {
        nestedChanged(subtreeVersion)
    }

    public final func localChanged() -> Bool {
        localChanged(subtreeVersion)
    }

    /**
     Discard versions until the value for `target` becomes effective.
     */
    public func dropVersions(through target: VersionId, recursive: Bool) {
        precondition(!isEditing)

        // if already at the target version, do nothing
        if target >= subtreeVersion { return }

        // update node version
        if target < nodeVersion {
            nodeVersion = target
        }
        // update nested change
        _nestedChangeVersions.drop(through: target)
    }

    public final func dropVersions(through target: VersionId) {
        dropVersions(through: target, recursive: true)
    }

    // MARK: - Editing

    public final func beginEditing(for version: VersionId) {
        // increment editing level
        _editingLevel += 1

        // if already editing, do nothing
        if _editingLevel > 1 {
            assert(version == subtreeVersion)
            return
        }

        // advance version
        _advanceVersion(to: version)
    }

    public final func endEditing() {
        precondition(_editingLevel > 0)

        // decrement editing level
        _editingLevel -= 1

        // propagate changes
        parent?._propagateNestedChanged(for: subtreeVersion)
    }

    // MARK: - Internal

    /**
     Advance the current version to `target`
     */
    func _advanceVersion(to target: VersionId) {
        precondition(target >= subtreeVersion)

        // update node version
        nodeVersion = target
    }

    final func _propagateNestedChanged(for version: VersionId) {
        precondition(version >= maxNestedVersion)

        // stop early if already at the target
        if version == maxNestedVersion { return }

        // update nested change
        _nestedChangeVersions.advance(to: version)

        // propagate to parent
        parent?._propagateNestedChanged(for: version)
    }

    func _propagateRangeLengthChanged(_ delta: Int) {
        parent?._propagateRangeLengthChanged(delta)
    }

    // MARK: - Visitor

    public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        preconditionFailure()
    }
}
