// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import RohanCommon
import Testing

struct NodeReconcileTests {
    @Test
    static func testNode() {
        let root = RootNode([
            HeadingNode(level: 1, [
                TextNode("Alpha "),
                EmphasisNode([
                    TextNode("Beta Charlie"),
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
                TextNode("😀 The equation is "),
                EquationNode(
                    isBlock: true,
                    nucleus: ContentNode([TextNode("a+b=c.")])
                ),
                TextNode("😀"),
            ]),
            ParagraphNode([
                TextNode("May the force be  with you!"),
            ]),
        ])

        let textLayoutManager = NSTextLayoutManager()
        let textContentStorage = NSTextContentStorage_fix()
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.textContainer = .init(size: CGSize(width: 200, height: 0))

        let visitor = ReconcileVisitor(textContentStorage: textContentStorage)
        textContentStorage.performEditingTransaction {
            _ = root.accept(visitor, 0)
        }
        textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)

        func draw(_ dirtyRect: CGRect) {
            guard let cgContext = NSGraphicsContext.current?.cgContext else { return }

            cgContext.saveGState()
            defer { cgContext.restoreGState() }

            // center content
            let usageBounds = textLayoutManager.usageBoundsForTextContainer
            let newOrigin = usageBounds.centered(in: dirtyRect).origin
            cgContext.translateBy(x: newOrigin.x, y: newOrigin.y)

            // fill usage bounds
            cgContext.setFillColor(NSColor.blue.withAlphaComponent(0.05).cgColor)
            cgContext.fill(usageBounds)

            // draw fragments
            let startLocation = textLayoutManager.documentRange.location
            textLayoutManager.enumerateTextLayoutFragments(from: startLocation) { fragement in
                // draw fragment
                fragement.draw(at: fragement.layoutFragmentFrame.origin, in: cgContext)

                // draw text attachments
                for viewProvider in fragement.textAttachmentViewProviders {
                    guard let view = viewProvider.view else { continue }

                    let fragmentOrigin = fragement.layoutFragmentFrame.origin
                    let frame = fragement.frameForTextAttachment(at: viewProvider.location)
                        .offsetBy(dx: fragmentOrigin.x, dy: fragmentOrigin.y)
                    view.frame = frame
                    view.draw(frame)
                }
                return true // continue
            }
        }

        guard let filePath = TestUtils.filePath(#function.dropLast(2), fileExtension: ".pdf")
        else { return }

        DrawUtils.drawPDF(filePath: filePath, isFlipped: true) { rect in
            draw(rect)
        }
    }
}

// R: consumed nsLength, C: start location
private final class ReconcileVisitor: NodeVisitor<Int, Int> {
    let textContentStorage: NSTextContentStorage

    init(textContentStorage: NSTextContentStorage) {
        self.textContentStorage = textContentStorage
    }

    func processBlockNode(_ node: Node, _ current: Int) -> Int {
        let last: Character? = { () -> Character? in
            if current == 0 { return nil }
            let code = (textContentStorage.textStorage!.string as NSString).character(at: current - 1)
            return UnicodeScalar(code).map(Character.init(_:))
        }()

        if last == nil || last!.isNewline {
            return 0
        }
        else if node.isBlock {
            _insertText(current, "\n", [:])
            return 1
        }
        return 0
    }

    override func visitNode(_ node: Node, _ context: Int) -> Int {
        var current = context

        if let element = node as? ElementNode {
            for i in 0 ..< element.childCount() {
                let nsLength = element.getChild(i).accept(self, current)
                current += nsLength
            }

            let nsLength = processBlockNode(node, current)
            current += nsLength

            return current - context
        }

        preconditionFailure()
    }

    override func visit(root: RootNode, _ context: Int) -> Int {
        let nsLength = visitNode(root, context)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
        ]

        textContentStorage.textStorage!
            .addAttributes(attributes, range: NSRange(location: 0, length: nsLength))

        return nsLength
    }

    override func visit(text: TextNode, _ context: Int) -> Int {
        let string = text.string
        _insertText(context, string, [:])
        return string.nsLength()
    }

    override func visit(equation: EquationNode, _ context: Int) -> Int {
        var current = context

        current += processBlockNode(equation, context)
        do {
            let attachment = MyTextAttachment(width: 12,
                                              ascent: 10, descent: 6)
            let attachmentString = NSAttributedString(attachment: attachment)
            _insertAttributedString(current, attachmentString)
            current += 1
        }
        current += processBlockNode(equation, current)

        return current - context
    }

    internal func _insertText(
        _ location: Int,
        _ text: String,
        _ attributes: [NSAttributedString.Key: Any]
    ) {
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        _insertAttributedString(location, attributedString)
    }

    internal func _insertAttributedString(
        _ location: Int,
        _ attributedString: NSAttributedString
    ) {
        // location
        let textLocation = textContentStorage.textLocation(for: location)!
        let textRange = NSTextRange(location: textLocation)
        // content
        let textParagraph = NSTextParagraph(attributedString: attributedString)
        // replace
        textContentStorage.replaceContents(in: textRange, with: [textParagraph])
    }
}
