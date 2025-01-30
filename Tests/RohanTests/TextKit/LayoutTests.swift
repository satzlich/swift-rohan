// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct LayoutTests {
    @Test
    static func testLayout() {
        let contentStorage = ContentStorage()
        let layoutManager = LayoutManager()

        // set up text container
        layoutManager.textContainer = NSTextContainer(size: CGSize(width: 200, height: 0))

        // set up layout manager
        contentStorage.setLayoutManager(layoutManager)
        #expect(contentStorage.layoutManager === layoutManager)
        #expect(layoutManager.contentStorage === contentStorage)

        do {
            let documentRange = layoutManager.documentRange
            let compareResult = documentRange.location.compare(documentRange.endLocation)
            #expect(compareResult == .orderedSame)
        }

        // insert content
        let content = [
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
                    nucleus: ContentNode([TextNode("f(n+2)=f(n+1)+f(n),")])
                ),
                TextNode("where "),
                EquationNode(
                    isBlock: false,
                    nucleus: ContentNode([TextNode("n")])
                ),
                TextNode(" is a natural number."),
            ]),
            ParagraphNode([
                TextNode("May the force be with you!"),
            ]),
        ]

        contentStorage.replaceContents(in: contentStorage.documentRange, with: content)

        // document range
        let documentRange = contentStorage.documentRange
        let compareResult = documentRange.location.compare(documentRange.endLocation)
        #expect(compareResult == .orderedAscending)

        let pageSize = CGSize(width: 540, height: 200)
        do {
            // ensure layout
            layoutManager.ensureLayout(delayed: false)
            #expect(contentStorage.rootNode.isDirty == false)

            // draw
            guard let filePath = TestUtils.filePath(#function.dropLast(2) + "_1",
                                                    fileExtension: ".pdf")
            else { return }
            DrawUtils.drawPDF(filePath: filePath,
                              pageSize: pageSize,
                              isFlipped: true)
            { bounds in
                guard let cgContext = NSGraphicsContext.current?.cgContext else { return }

                draw(bounds, layoutManager.textLayoutManager, cgContext)
            }
        }

        do {
            // delete
            (contentStorage.rootNode.getChild(0) as! HeadingNode)
                .removeChild(at: 1, inContentStorage: true)
            #expect(contentStorage.rootNode.isDirty == true)
            // ensure layout
            layoutManager.ensureLayout(delayed: false)
            #expect(contentStorage.rootNode.isDirty == false)

            // draw
            guard let filePath = TestUtils.filePath(#function.dropLast(2) + "_2",
                                                    fileExtension: ".pdf")
            else { return }
            DrawUtils.drawPDF(filePath: filePath,
                              pageSize: pageSize,
                              isFlipped: true)
            { bounds in
                guard let cgContext = NSGraphicsContext.current?.cgContext else { return }

                draw(bounds, layoutManager.textLayoutManager, cgContext)
            }
        }

        do {
            // insert
            (contentStorage.rootNode.getChild(0) as! HeadingNode)
                .insertChild(TextNode("2025 "), at: 0, inContentStorage: true)
            #expect(contentStorage.rootNode.isDirty == true)
            // ensure layout
            layoutManager.ensureLayout(delayed: false)
            #expect(contentStorage.rootNode.isDirty == false)

            // draw
            guard let filePath = TestUtils.filePath(#function.dropLast(2) + "_3",
                                                    fileExtension: ".pdf")
            else { return }
            DrawUtils.drawPDF(filePath: filePath,
                              pageSize: pageSize,
                              isFlipped: true)
            { bounds in
                guard let cgContext = NSGraphicsContext.current?.cgContext else { return }

                draw(bounds, layoutManager.textLayoutManager, cgContext)

                let newBounds = CGRect(x: bounds.width / 2, y: 0,
                                       width: bounds.width / 2, height: bounds.height)
                MathFragmentTests.drawSample("Latin Modern Math", newBounds, cgContext)

                let originY = 77.0

                // draw line (0, originY) -> (bounds.width, originY) using cgContext
                cgContext.setStrokeColor(NSColor.blue.withAlphaComponent(0.05).cgColor)
                cgContext.move(to: CGPoint(x: 0, y: originY))
                cgContext.addLine(to: CGPoint(x: bounds.width, y: originY))
                cgContext.strokePath()
            }
        }
    }

    static func draw(_ bounds: CGRect,
                     _ textLayoutManager: NSTextLayoutManager,
                     _ cgContext: CGContext)
    {
        cgContext.saveGState()
        defer { cgContext.restoreGState() }

        let usageBounds = textLayoutManager.usageBoundsForTextContainer

        // fill usage bounds
        cgContext.saveGState()
        cgContext.setFillColor(NSColor.blue.withAlphaComponent(0.05).cgColor)
        cgContext.fill(usageBounds)
        cgContext.restoreGState()

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
}
