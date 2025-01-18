// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct LayoutIncubatorTests {
    @Test
    static func testBasic() {
        let root = RootNode([
            ParagraphNode([
                TextNode("The formula is "),
                EquationNode(
                    isBlock: true,
                    nucleus: ContentNode([
                        TextNode("f(n+2) = f(n+1) + f(n)"),
                        TextModeNode([
                            TextNode(", where "),
                        ]),
                        TextNode("n"),
                        TextModeNode([
                            TextNode(" is a natural number."),
                        ]),
                    ])
                ),
            ]),
        ])

        #expect(root.synopsis() ==
            """
            The formula is ꞈf(n+2) = f(n+1) + f(n)ꞈ, where ꞈnꞈ is a natural number.
            """)
    }
}
