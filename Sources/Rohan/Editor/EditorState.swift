//// Copyright 2024-2025 Lie Yan
//
//import Collections
//import Foundation
//
//typealias NodeMap = TreeDictionary<NodeKey, Node>
//
//final class EditorState { // model
//    /*
//     Invariant: root ∈ nodeMap.keys
//     */
//
//    var nodeMap: NodeMap
//    var selection: (any SelectionProtocol)?
//    var rootNodeKey: NodeKey
//
//    init(nodeMap: NodeMap, selection: (any SelectionProtocol)? = nil) {
//        self.nodeMap = nodeMap
//        self.selection = selection
//        self.rootNodeKey = .defaultInitial
//    }
//
//    convenience init() {
//        self.init(nodeMap: NodeMap(), selection: nil)
//    }
//}
//
//struct UndoRecord {
//    /** editor state to restore */
//    let editorState: EditorState
//    /**
//     dirty nodes between the editor state to restore and the editor state
//     to restore from
//     */
//    let dirtyNodes: Set<NodeKey>
//}
