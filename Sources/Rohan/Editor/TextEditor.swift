// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

class TextEditor { // controller
    // constituents

    var state: EditorState
    var pendingState: EditorState?
    var dirtyNodes: Dictionary<ObjectIdentifier, Node>

    // context

    let styleSheet: StyleSheet
    /** The size of the text container's bounding rectangle.

     For each axis, a value of `0` or less means no limitation.
     */
    var containerSize: CGSize {
        didSet { }
    }

    // properties

    var inEditTransaction: Bool = false

    // relations

    weak var parent: TextEditor?

    init(state: EditorState, styleSheet: StyleSheet, containerSize: CGSize? = nil) {
        self.state = state
        self.pendingState = nil
        self.dirtyNodes = Dictionary()
        self.styleSheet = styleSheet
        self.containerSize = containerSize ?? .init(width: 10_000_000, height: 10_000_000)
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
