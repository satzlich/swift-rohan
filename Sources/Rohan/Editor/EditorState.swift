// Copyright 2024-2025 Lie Yan

import Collections
import Foundation

struct EditorState {
    /** The current version of the document. */
    public let version: VersionId
    /** The nodes of the document. */
    public var nodeMap: TreeDictionary<ObjectIdentifier, Node>
    /** The current selection. */
    public var selection: (any SelectionProtocol)?
    /** The root node of the document. */
    public let rootNode: RootNode

    private init(_ editorState: EditorState, _ version: VersionId) {
        self.version = version
        self.nodeMap = editorState.nodeMap
        self.selection = editorState.selection
        self.rootNode = editorState.rootNode
    }

    func clone(to version: VersionId?) -> EditorState {
        EditorState(self, version ?? self.version)
    }

    init(_ version: VersionId, _ content: [Node]) {
        self.version = version
        self.nodeMap = TreeDictionary()
        self.selection = nil
        self.rootNode = RootNode(content, version)
    }
}
