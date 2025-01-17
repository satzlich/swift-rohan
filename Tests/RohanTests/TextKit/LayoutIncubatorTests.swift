// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct LayoutIncubatorTests {
    @Test
    static func testBasic() {
        let root = RootNode([
            ParagraphNode([
                TextNode("The equation is "),
                EquationNode(
                    isBlock: false,
                    nucleus: ContentNode([TextNode("a+b.")])
                ),
            ]),
        ])

        useValue(root)
    }
}
