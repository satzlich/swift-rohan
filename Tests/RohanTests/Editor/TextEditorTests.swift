// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import CoreGraphics
import Foundation
import Testing

struct TextEditorTests {
    @Test
    static func testTextEditor() {
        let editorState = EditorState(VersionId.defaultInitial, sampelText())
        let styleSheet = StyleSheetTests.sampleStyleSheet()
        let editor = TextEditor(state: editorState, styleSheet: styleSheet)

        editor.reconcile()

        do {
            let fileName = #function.dropLast(2).appending("_layoutFragments")
            let filePath = TestUtils.filePath(fileName, fileExtension: ".pdf")!
            let success = DrawUtils.drawPDF(filePath: filePath, isFlipped: true) { rect in
                guard let cgContext = NSGraphicsContext.current?.cgContext
                else { return }

                cgContext.saveGState()
                do {
                    // center the content
                    let newRect = editor.layoutBounds.centered(in: rect)
                    cgContext.translateBy(x: newRect.origin.x, y: newRect.origin.y)
                    // draw
                    editor.draw(editor.layoutBounds)
                }
                cgContext.restoreGState()
            }
            #expect(success)
        }

        do {
            guard let textStorage = editor.textContentManager as? NSTextContentStorage,
                  let attributedString = textStorage.attributedString
            else { preconditionFailure() }

            let fileName = #function.dropLast(2).appending("_attributedString")
            let filePath = TestUtils.filePath(fileName, fileExtension: ".pdf")!
            let success = DrawUtils.drawPDF(filePath: filePath) {
                DrawUtils.draw(attributedString: attributedString, in: $0)
            }
            #expect(success)
        }
    }

    private static func sampelText() -> [Node] {
        [
            HeadingNode(
                level: 1,
                [
                    TextNode("Sample "),
                    EmphasisNode([TextNode("Text")]),
                ]
            ),
            ParagraphNode(
                [
                    TextNode("The quick brown fox "),
                    EmphasisNode([
                        TextNode("jumps over the "),
                        EmphasisNode([TextNode("lazy ")]),
                        TextNode("dog."),
                    ]),
                ]
            ),
            ParagraphNode([
                TextNode("The equation is "),
                EquationNode(
                    isBlock: false,
                    nucleus: ContentNode([TextNode("a+b=c")])
                ),
                TextNode("."),
            ]),
        ]
    }
}
