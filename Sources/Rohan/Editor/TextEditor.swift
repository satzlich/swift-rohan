//// Copyright 2024-2025 Lie Yan
//
//import AppKit
//import Collections
//import Foundation
//
///*
//
// Nodes
//    root
//    text
//    paragraph
//    heading
//    equation
//
// the loop:
//    edit() -> pendingState
//    reconcile() -> undoRecord
// */
//
//final class TextEditor: Editor {
//    var textContentManager: NSTextContentManager {
//        _textContentStorage
//    }
//
//    private var _textContentStorage: NSTextContentStorage = .init()
//    private var textLayoutManager: NSTextLayoutManager = .init()
//
//    override init(state: EditorState) {
//        super.init(state: state)
//    }
//
//    func insertText(_ string: String) {
//        precondition(inEditTransaction && pendingState != nil)
//    }
//
//    private func replaceContents(
//        _ selection: (any SelectionProtocol),
//        _ text: TextNode
//    ) {
//        //
//    }
//}
