// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct EditTests {
    @Test
    static func testInsert() {
        // create content storage and layout manager
        let contentStorage = ContentStorage(
            RootNode([
                HeadingNode(level: 1, [
                    EmphasisNode([TextNode("Fibonacci😀")]),
                ]),
                ParagraphNode([
                    EquationNode(isBlock: true, [
                        TextNode("f(n+2)=f(n+1)"),
                    ]),
                ]),
            ])
        )
        let layoutManager = LayoutManager(StyleSheetTests.sampleStyleSheet())

        // set up text container
        let pageSize = CGSize(width: 250, height: 200)
        layoutManager.textContainer = NSTextContainer(size: CGSize(width: pageSize.width,
                                                                   height: 0))

        // set up layout manager
        contentStorage.setLayoutManager(layoutManager)

        // check document
        #expect(contentStorage.rootNode.prettyPrint() ==
            """
            root
             ├ heading
             │  └ emphasis
             │     └ text "Fibonacci😀"
             └ paragraph
                └ equation
                   └ nucleus
                      └ text "f(n+2)=f(n+1)"
            """)

        // function for outputting PDF
        func outputPDF(_ functionName: String, _ n: Int) {
            layoutManager.ensureLayout(delayed: false)
            #expect(contentStorage.rootNode.isDirty == false)
            guard let filePath = TestUtils.filePath(functionName.dropLast(2) + "_\(n)",
                                                    fileExtension: ".pdf")
            else { return }
            let pageSize = CGSize(width: 270, height: 200)
            DrawUtils.drawPDF(filePath: filePath, pageSize: pageSize,
                              isFlipped: true)
            { bounds in
                guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
                LayoutTests.draw(bounds, layoutManager.textLayoutManager, cgContext)
            }
        }
        outputPDF(#function, 1)

        // do insertion in the middle of a text node
        do {
            let path: [RohanIndex] = [
                .nodeIndex(0), // heading
                .nodeIndex(0), // emphasis
                .nodeIndex(0), // text "Fibonacci😀"
            ]
            let offset = "Fibonacci".count
            let range = RhTextRange(location: RohanTextLocation(path, offset))

            try! contentStorage.replaceContents(in: range, with: " Sequence")
        }
        // check document
        #expect(contentStorage.rootNode.prettyPrint() ==
            """
            root
             ├ heading
             │  └ emphasis
             │     └ text "Fibonacci Sequence😀"
             └ paragraph
                └ equation
                   └ nucleus
                      └ text "f(n+2)=f(n+1)"
            """)
        // output PDF
        outputPDF(#function, 2)

        // do insertion in the root
        do {
            let location = RohanTextLocation([], 1)
            let range = RhTextRange(location: location)
            try! contentStorage.replaceContents(in: range, with: "is defined as follows:")
        }
        // check document
        #expect(contentStorage.rootNode.prettyPrint() ==
            """
            root
             ├ heading
             │  └ emphasis
             │     └ text "Fibonacci Sequence😀"
             └ paragraph
                ├ text "is defined as follows:"
                └ equation
                   └ nucleus
                      └ text "f(n+2)=f(n+1)"
            """)
        // output PDF
        outputPDF(#function, 3)

        // do insertion in the root
        do {
            let location = RohanTextLocation([], 1)
            let range = RhTextRange(location: location)
            try! contentStorage.replaceContents(in: range, with: "Fibonacci sequence ")
        }
        // check document
        #expect(contentStorage.rootNode.prettyPrint() ==
            """
            root
             ├ heading
             │  └ emphasis
             │     └ text "Fibonacci Sequence😀"
             └ paragraph
                ├ text "Fibonacci sequence is defined as follows:"
                └ equation
                   └ nucleus
                      └ text "f(n+2)=f(n+1)"
            """)
        // output PDF
        outputPDF(#function, 4)

        // do insertion in the root
        do {
            let location = RohanTextLocation([], 2)
            let range = RhTextRange(location: location)
            try! contentStorage.replaceContents(in: range, with: "Veni. Vidi. Vici.")
        }
        // check document
        #expect(contentStorage.rootNode.prettyPrint() ==
            """
            root
             ├ heading
             │  └ emphasis
             │     └ text "Fibonacci Sequence😀"
             └ paragraph
                ├ text "Fibonacci sequence is defined as follows:"
                ├ equation
                │  └ nucleus
                │     └ text "f(n+2)=f(n+1)"
                └ text "Veni. Vidi. Vici."
            """)

        // output PDF
        outputPDF(#function, 5)

        // do insertion in the nucleus
        do {
            let path: [RohanIndex] = [
                .nodeIndex(1), // paragraph
                .nodeIndex(1), // equation
                .mathIndex(.nucleus), // nucleus
            ]
            let offset = 1
            let range = RhTextRange(location: RohanTextLocation(path, offset))
            try! contentStorage.replaceContents(in: range, with: "+f(n).")
        }

        // check document
        #expect(contentStorage.rootNode.prettyPrint() ==
            """
            root
             ├ heading
             │  └ emphasis
             │     └ text "Fibonacci Sequence😀"
             └ paragraph
                ├ text "Fibonacci sequence is defined as follows:"
                ├ equation
                │  └ nucleus
                │     └ text "f(n+2)=f(n+1)+f(n)."
                └ text "Veni. Vidi. Vici."
            """)

        // output PDF
        outputPDF(#function, 6)
    }
}
