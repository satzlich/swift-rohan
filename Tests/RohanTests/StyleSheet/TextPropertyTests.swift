// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Rohan
import Testing

struct TextPropertyTests {
    @Test
    static func test_fontDescriptor() {
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
        let attributes = textProperty.attributeDictionary()
        let attributedString = NSAttributedString(string: "Hello, world!",
                                                  attributes: attributes)

        let filePath = TestUtils.filePath(for: #function, extension: ".pdf")!
        ImageUtils.drawPDF(filePath: filePath) {
            ImageUtils.draw(attributedString: attributedString, in: $0)
        }
    }

    @Test
    static func test_drawCGContext() {
        // form text property
        let textProperty = TextProperty(
            font: "Latin Modern Sans",
            size: FontSize(12),
            stretch: .normal,
            style: .italic,
            weight: .bold,
            foregroundColor: .blue
        )

        // form attributed string
        let attributes = textProperty.attributeDictionary()
        let attributedString = NSAttributedString(string: "Hello, world!",
                                                  attributes: attributes)

        let filePath = TestUtils.filePath(for: #function, extension: ".pdf")!
        ImageUtils.drawPDF(filePath: filePath) {
            ImageUtils.draw(attributedString: attributedString, in: $0)
        }
    }
}
