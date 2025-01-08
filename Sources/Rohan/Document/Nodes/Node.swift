// Copyright 2024-2025 Lie Yan

import Foundation

enum SubtreeScope {
    case root
    case descendants
}

/**
 Persistent node
 */
class Node {
    // relations

    weak var _parent: Node? // unversioned
    var parent: Node? { _parent }

    // propreties

    class var type: NodeType {
        .unknown
    }

    public final var type: NodeType {
        Self.type
    }

    /*
     Invariants:
        currentVersion >= maxVersion => currentVersion == maxVersion
        maxVersion = max(currentVersion, max { child.maxVersion })
        max(_nestedChange) <= maxVersion
        currentVersion < maxVersion => max(_nestedChange) == maxVersion
     */

    public private(set) var currentVersion: VersionId
    /** max version in the subtree */
    public private(set) var maxVersion: VersionId
    /** the versions where descendants changed at */
    private var _nestedChange: Set<VersionId>

    // helper variables

    private var isEditing: Bool = false

    public init(_ version: VersionId = .defaultInitial) {
        self.currentVersion = version
        self.maxVersion = version
        self._nestedChange = .init()
    }

    /**
     Returns true if any descendants are locally changed at `version`.
     */
    public func nestedChanged(_ version: VersionId) -> Bool {
        _nestedChange.contains(version)
    }

    /**
     Returns true if this node is locally changed at `version`.
     */
    public func localChanged(_ version: VersionId) -> Bool {
        false
    }

    public final func nestedChanged() -> Bool {
        nestedChanged(currentVersion)
    }

    public final func localChanged() -> Bool {
        localChanged(currentVersion)
    }

    /**
     Discard versions until the value for `target` becomes effective.
     */
    public func dropVersions(through target: VersionId) {
        if target >= maxVersion { return }

        maxVersion = target
        if target < currentVersion {
            currentVersion = target
        }
        // TODO: optimise
        _nestedChange = _nestedChange.filter { $0 <= target }
    }

    public func beginEditing(for version: VersionId) {
        precondition(isEditing == false)
        isEditing = true
        _alterVersion(version)
    }

    public func endEditing() {
        precondition(isEditing == true)
        isEditing = false
        parent?._markNestedChanged(for: currentVersion)
    }

    // MARK: - Node and SubClass

    /**
     Set the value at the current version
     */
    func _alterVersion(_ target: VersionId) {
        precondition(target >= currentVersion)
        currentVersion = target
        if currentVersion > maxVersion {
            maxVersion = currentVersion
        }
    }

    final func _markNestedChanged(for version: VersionId) {
        precondition(version >= maxVersion)

        maxVersion = version
        _nestedChange.insert(version)
        parent?._markNestedChanged(for: version)
    }

    func synopsis(_ version: VersionId) -> String {
        ""
    }

    final func synopsis() -> String {
        synopsis(currentVersion)
    }
}
