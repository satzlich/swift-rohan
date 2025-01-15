// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Rohan
import Testing

struct TextPropertyTests {
    @Test
    static func testTextProperty() {
        // form text property
        let textProperty = TextProperty(
            font: "Latin Modern Roman",
            size: FontSize(12),
            stretch: .normal,
            style: .italic,
            weight: .bold,
            foregroundColor: .blue
        )

        // form attributed string
        let attributedString = NSAttributedString(string: "Hello, world!",
                                                  attributes: textProperty.attributes())

        let filePath = TestUtils.filePath(#function.dropLast(2), fileExtension: ".pdf")!
        let success = DrawUtils.drawPDF(filePath: filePath) {
            DrawUtils.draw(attributedString: attributedString, in: $0)
        }
        #expect(success)
    }
}
