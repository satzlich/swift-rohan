// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public enum ImageUtils {
    @discardableResult
    public static func drawText(attributedString: NSAttributedString,
                                in rect: NSRect,
                                backgroundColor: NSColor = .white) -> Bool
    {
        // fill background
        backgroundColor.setFill()
        NSBezierPath(rect: rect).fill()

        // Center the text in the image
        let textSize = attributedString.size()
        let textOrigin = NSPoint(
            x: rect.minX + (rect.width - textSize.width) / 2,
            y: rect.minY + (rect.height - textSize.height) / 2
        )

        // draw
        attributedString.draw(in: NSRect(origin: textOrigin, size: textSize))

        return true
    }

    public static func drawToCGContext(
        attributedString: NSAttributedString,
        in rect: NSRect,
        cgContext: CGContext,
        backgroundColor: CGColor = NSColor.white.cgColor
    ) {
        let old = NSGraphicsContext.current
        defer { NSGraphicsContext.current = old }

        NSGraphicsContext.current = NSGraphicsContext(cgContext: cgContext,
                                                      flipped: false)

        drawText(attributedString: attributedString,
                 in: rect,
                 backgroundColor: NSColor(cgColor: backgroundColor) ?? .white)
    }

    public static func createCGContext(forImageSize size: CGSize) -> CGContext? {
        // Create a bitmap-based CGContext
        CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8, // 8 bits per color component
            bytesPerRow: 0, // Automatically calculated
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue // RGBA format
        )
    }

    public static func drawToImage(attributedString: NSAttributedString,
                                   imageSize: NSSize,
                                   backgroundColor: NSColor = .white) -> NSImage
    {
        let image = NSImage(size: imageSize)
        image.lockFocus()
        drawText(attributedString: attributedString,
                 in: NSRect(origin: .zero, size: imageSize),
                 backgroundColor: backgroundColor)
        image.unlockFocus()
        return image
    }

    public static func writeImage(_ image: NSImage, with functionName: String) {
        let imageData = image.tiffRepresentation
        let fileURL = URL(fileURLWithPath: filePath(functionName)!)
        try? imageData?.write(to: fileURL)
    }

    private static func filePath(_ baseName: String) -> String? {
        // obtain output dir
        guard let baseDir = ProcessInfo().environment["RH_OUTPUT_DIR"] else {
            return nil
        }

        let baseName = baseName.trimmingCharacters(in: ["(", ")"])
        return "\(baseDir)/\(baseName).tiff"
    }
}
