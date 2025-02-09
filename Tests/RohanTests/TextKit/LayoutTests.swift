// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import CoreGraphics
import Foundation
import Testing

struct LayoutTests {
    @Test
    static func testLayout() {
        let contentStorage = ContentStorage()
        let layoutManager = LayoutManager(StyleSheetTests.sampleStyleSheet())

        // set up text container
        layoutManager.textContainer = NSTextContainer(size: CGSize(width: 200, height: 0))

        // set up layout manager
        contentStorage.setLayoutManager(layoutManager)
        #expect(contentStorage.layoutManager === layoutManager)
        #expect(layoutManager.contentStorage === contentStorage)

        // insert content
        let content = [
            HeadingNode(level: 1, [
                TextNode("Alpha "),
                EmphasisNode([
                    TextNode("Bravo Charlie"),
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
                    [
                        TextNode("f(n)+"),
                        FractionNode([TextNode("g(n+1)")],
                                     [TextNode("h(n+2)")]),
                    ]
                ),
                TextNode("where "),
                EquationNode(
                    isBlock: false,
                    [TextNode("n")]
                ),
                TextNode(" is a natural number."),
                EquationNode(
                    isBlock: true,
                    [
                        TextNode("f(n+2)=f(n+1)+f(n)"),
                    ]
                ),
            ]),
            ParagraphNode([
                TextNode("May the force be with you!"),
            ]),
        ]

        try! contentStorage.replaceContents(in: contentStorage.documentRange,
                                            with: content)

        func outputPDF(_ functionName: String, _ n: Int) {
            TestUtils.outputPDF(functionName.dropLast(2) + "_\(n)",
                                CGSize(width: 270, height: 200),
                                layoutManager)
            #expect(contentStorage.rootNode.isDirty == false)
        }

        // output PDF
        outputPDF(#function, 1)
        // delete
        (contentStorage.rootNode.getChild(0) as! HeadingNode)
            .removeChild(at: 1, inContentStorage: true)
        #expect(contentStorage.rootNode.isDirty == true)
        // output PDF
        outputPDF(#function, 2)

        // insert
        (contentStorage.rootNode.getChild(0) as! HeadingNode)
            .insertChild(TextNode("2025 "), at: 0, inContentStorage: true)
        #expect(contentStorage.rootNode.isDirty == true)
        // output PDF
        outputPDF(#function, 3)
    }

    @Test
    static func testFraction() {
        let contentStorage = ContentStorage()
        let layoutManager = LayoutManager(StyleSheetTests.sampleStyleSheet())

        // set up text container
        let pageSize = CGSize(width: 250, height: 200)
        layoutManager.textContainer = NSTextContainer(size: CGSize(width: pageSize.width,
                                                                   height: 0))

        // set up layout manager
        contentStorage.setLayoutManager(layoutManager)

        // set up content
        let content = [
            HeadingNode(level: 1, [
                TextNode("Alpha "),
                EquationNode(
                    isBlock: false,
                    [
                        FractionNode([TextNode("m+n")],
                                     [TextNode("n")]),
                    ]
                ),
            ]),
            ParagraphNode([
                TextNode("The equation is "),
                EquationNode(
                    isBlock: false,
                    [
                        TextNode("f(n)+"),
                        FractionNode([TextNode("m+n")],
                                     [TextNode("n")],
                                     isBinomial: true),
                        TextNode("+"),
                        FractionNode([TextNode("m+n")],
                                     [TextNode("n")]),
                        TextNode("-k."),
                    ]
                ),
            ]),
        ]
        try! contentStorage.replaceContents(in: contentStorage.documentRange,
                                            with: content)

        func outputPDF(_ functionName: String, _ n: Int) {
            TestUtils.outputPDF(functionName.dropLast(2) + "_\(n)",
                                pageSize, layoutManager)
            #expect(contentStorage.rootNode.isDirty == false)
        }

        outputPDF(#function, 1)
        // replace
        ((contentStorage.rootNode.getChild(0) as! HeadingNode)
            .getChild(1) as! EquationNode)
            .nucleus
            .insertChild(TextNode("-c>100"), at: 1, inContentStorage: true)
        #expect(contentStorage.rootNode.isDirty == true)
        outputPDF(#function, 2)

        // remove
        ((contentStorage.rootNode.getChild(0) as! HeadingNode)
            .getChild(1) as! EquationNode)
            .nucleus
            .removeChild(at: 0, inContentStorage: true)
        #expect(contentStorage.rootNode.isDirty == true)
        outputPDF(#function, 3)
    }
}
