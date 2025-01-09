// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

class TextEditor { // controller
    // constituents

    var state: EditorState
    var pendingState: EditorState?
    var dirtyNodes: Dictionary<ObjectIdentifier, Node>

    // properties

    var inEditTransaction: Bool = false

    // relations

    weak var parent: TextEditor?

    init(state: EditorState) {
        self.state = state
        self.pendingState = nil
        self.dirtyNodes = Dictionary()
    }

    final func performEditTransaction(_ closure: () -> Void) {
        beginEditTransaction()
        closure()
        endEditTransaction()
    }

    private func beginEditTransaction() {
        precondition(inEditTransaction == false)
        inEditTransaction = true
    }

    private func endEditTransaction() {
        precondition(inEditTransaction == true)
        inEditTransaction = false
    }

    var textContentManager: NSTextContentManager {
        _textContentStorage
    }

    private var _textContentStorage: NSTextContentStorage = .init()
    private var textLayoutManager: NSTextLayoutManager = .init()

    func insertText(_ string: String) {
        precondition(inEditTransaction && pendingState != nil)
    }

    private func replaceContents(
        _ selection: (any SelectionProtocol),
        _ text: TextNode
    ) {
        //
    }
}

func sampleText() -> [Node] {
    [
        HeadingNode(
            level: 1,
            [
                TextNode("The "),
                EmphasisNode(
                    [
                        TextNode("quick "),
                    ]
                ),
            ]
        ),
        ParagraphNode(
            [
                TextNode("brown "),
                EmphasisNode(
                    [
                        TextNode("fox "),
                    ]
                ),
                EquationNode(
                    isBlock: false,
                    nucleus: ContentNode(
                        [
                            TextNode("a = b"),
                        ]
                    )
                ),
            ]
        ),
    ]
}
