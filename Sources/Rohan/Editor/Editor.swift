//// Copyright 2024-2025 Lie Yan
//
//import AppKit
//import Foundation
//
//class Editor { // controller
//    // constituents
//
//    var state: EditorState
//    var pendingState: EditorState?
//    /** dirty nodes between editorState and pendingEditorState */
//    var dirtyNodes: Set<NodeKey>
//
//    // properties
//
//    var inEditTransaction: Bool = false
//
//    // relations
//
//    weak var parent: Editor?
//    var view: NSView
//
//    init(state: EditorState) {
//        self.state = state
//        self.pendingState = nil
//        self.dirtyNodes = .init()
//        self.view = NSView()
//    }
//
//    final func performEditTransaction(_ closure: () -> Void) {
//        beginEditTransaction()
//        closure()
//        endEditTransaction()
//    }
//
//    private func beginEditTransaction() {
//        precondition(inEditTransaction == false)
//        inEditTransaction = true
//    }
//
//    private func endEditTransaction() {
//        precondition(inEditTransaction == true)
//        inEditTransaction = false
//    }
//}
//
//final class EditorNode: Node {
//    override class var type: NodeType {
//        .editor
//    }
//
//    private let editor: Editor
//
//    init(_ key: NodeKey, _ editor: Editor) {
//        self.editor = editor
//        super.init(key)
//    }
//}
