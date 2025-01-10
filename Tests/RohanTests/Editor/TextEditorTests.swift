// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct TextEditorTests {
    @Test
    static func testTextEditor() {
        let editorState = EditorState(VersionId.defaultInitial, NodeTests.sampleContent())
        let styleSheet = StyleSheetTests.sampleStyleSheet()
        let editor = TextEditor(state: editorState, styleSheet: styleSheet)

        editor.reconcile()

        guard let textStorage = editor.textContentManager as? NSTextContentStorage,
              let attributedString = textStorage.attributedString
        else { preconditionFailure() }

        let filePath = TestUtils.filePath(for: #function, extension: ".pdf")!
        ImageUtils.drawPDF(filePath: filePath) {
            ImageUtils.draw(attributedString: attributedString, in: $0)
        }
    }
}
