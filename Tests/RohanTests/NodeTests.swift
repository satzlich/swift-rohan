// Copyright 2024-2025 Lie Yan

@testable import Rohan
import RohanCommon
import AppKit
import Foundation
import Testing

struct NodeTests {
    @Test
    static func testNode() {
        let root = RootNode([
            HeadingNode(level: 1, [
                TextNode("Alpha "),
                EmphasisNode([
                    TextNode("Beta Charlie 😀"),
                ]),
            ]),
            ParagraphNode([
                TextNode("The quick brown fox "),
                EmphasisNode([
                    TextNode("jumps over the "),
                    EmphasisNode([
                        TextNode("lazy "),
                    ]),
                    TextNode("dog."),
                ]),
            ]),
            ParagraphNode([
                TextNode("The equation is "),
                EquationNode(
                    isBlock: false,
                    nucleus: ContentNode([TextNode("a+b=c")])
                ),
                TextNode("."),
            ]),
        ])

        let textLayoutManager = NSTextLayoutManager()
        let textContentStorage = NSTextContentStorage_fix()
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.textContainer = .init(size: CGSize(width: 200, height: 0))

        func draw(_ dirtyRect: CGRect) {
            guard let cgContext = NSGraphicsContext.current?.cgContext else { return }

            let startLocation = textLayoutManager.documentRange.location
            textLayoutManager.enumerateTextLayoutFragments(from: startLocation) { fragement in
                fragement.draw(at: fragement.layoutFragmentFrame.origin, in: cgContext)
                return true // continue
            }
        }
        
        let visitor = ReconcileVisitor(textContentStorage: textContentStorage)
        textContentStorage.performEditingTransaction {
            _ = root.accept(visitor, 0)
        }
        guard let filePath = TestUtils.filePath(#function.dropLast(2), fileExtension: ".pdf")
        else { return }

        DrawUtils.drawPDF(filePath: filePath, isFlipped: true) { rect in
            draw(rect)
        }
    }
}

private final class ReconcileVisitor: NodeVisitor<Int, Int>
// R: consumed lengthAsNSString, C: start location
{
    let textContentStorage: NSTextContentStorage

    init(textContentStorage: NSTextContentStorage) {
        self.textContentStorage = textContentStorage
    }

    override func visitNode(_ node: Node, _ context: Int) -> Int {
        var current = context

        if let element = node as? ElementNode {
            for i in 0 ..< element.childCount() {
                let nsLength = element.getChild(i).accept(self, current)
                current += nsLength
            }

            return current - context
        }
        preconditionFailure()
    }

    override func visit(text: TextNode, _ context: Int) -> Int {
        let string = text.string
        _insertText(context, string, [:])
        return string.lengthAsNSString()
    }

    override func visit(equation: EquationNode, _ context: Int) -> Int {
        let string = "□"
        _insertText(context, string, [:])
        return string.lengthAsNSString()
    }

    internal func _insertText(
        _ location: Int,
        _ text: String,
        _ attributes: [NSAttributedString.Key: Any]
    ) {
        // location
        let textLocation = textContentStorage.textLocation(for: location)!
        let textRange = NSTextRange(location: textLocation)
        // content
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textParagraph = NSTextParagraph(attributedString: attributedString)
        // replace
        textContentStorage.replaceContents(in: textRange, with: [textParagraph])
    }
}
