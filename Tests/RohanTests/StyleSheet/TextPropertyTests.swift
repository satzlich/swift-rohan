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

        // form image
        let image = ImageUtils.drawToImage(attributedString: attributedString,
                                           imageSize: NSSize(width: 200, height: 120),
                                           backgroundColor: .white)

        ImageUtils.writeImage(image, with: #function)
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

        //
        let imageSize = NSSize(width: 200, height: 120)
        let cgContext = ImageUtils.createCGContext(forImageSize: imageSize)!
        ImageUtils.drawToCGContext(attributedString: attributedString,
                                   in: CGRect(origin: .zero, size: imageSize),
                                   cgContext: cgContext)

        //
        guard let cgImage = cgContext.makeImage() else { return }
        let image = NSImage(cgImage: cgImage, size: imageSize)

        ImageUtils.writeImage(image, with: #function)
    }
}
