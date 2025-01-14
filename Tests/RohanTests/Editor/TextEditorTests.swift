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
        let editor = Editor(state: editorState,
                                styleSheet: styleSheet,
                                containerSize: NSSize(width: 200, height: 0))

        editor.reconcile()

        let fileName = #function.dropLast(2).appending("_layoutFragments")
        let filePath = TestUtils.filePath(fileName, fileExtension: ".pdf")!
        let success = DrawUtils.drawPDF(filePath: filePath, isFlipped: true) { rect in
            guard let cgContext = NSGraphicsContext.current?.cgContext
            else { return }

            cgContext.saveGState()
            do {
                // get bounds
                let bounds = editor.usageBounds

                // center content
                let newOrigin = bounds.centered(in: rect).origin
                cgContext.translateBy(x: newOrigin.x,
                                      y: newOrigin.y)

                // draw background
                cgContext.setFillColor(NSColor.orange.withAlphaComponent(0.05).cgColor)
                cgContext.fill(bounds)

                // draw content
                editor.draw(bounds)
            }
            cgContext.restoreGState()
        }
        #expect(success)
    }

    private static func sampelText() -> [Node] {
        [
            HeadingNode(
                level: 1,
                [
                    TextNode("Alpha "),
                    EmphasisNode([TextNode("Bravo Charlie 😀")]),
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
