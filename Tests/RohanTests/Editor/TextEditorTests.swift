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

        let image = ImageUtils.drawToImage(attributedString: attributedString,
                                           imageSize: NSSize(width: 200, height: 120),
                                           backgroundColor: .white)
        ImageUtils.writeImage(image, with: #function)
    }
}
