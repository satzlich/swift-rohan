// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public enum ImageUtils {
    @discardableResult
    public static func drawTIFF(filePath: String,
                                imageSize: NSSize = NSSize(width: 200, height: 120),
                                backgroundColor: NSColor = .white,
                                drawingHandler: (NSRect) -> Void) -> Bool
    {
        let image = drawImage(size: imageSize,
                              backgroundColor: backgroundColor,
                              drawingHandler: drawingHandler)
        guard let image else { return false }
        let imageData = image.tiffRepresentation
        let fileURL = URL(fileURLWithPath: filePath)
        let result: ()? = try? imageData?.write(to: fileURL)
        return result != nil
    }

    @discardableResult
    public static func drawPDF(filePath: String,
                               pageSize: NSSize = NSSize(width: 200, height: 120),
                               drawingHandler: (NSRect) -> Void) -> Bool
    {
        let filePath = URL(fileURLWithPath: filePath)
        var pageRect = NSRect(origin: .zero, size: pageSize)

        // create PDF context
        guard let pdfContext = CGContext(filePath as CFURL, mediaBox: &pageRect, nil)
        else { return false }

        // switch context
        let previous = NSGraphicsContext.current
        NSGraphicsContext.current = NSGraphicsContext(cgContext: pdfContext, flipped: false)
        defer { NSGraphicsContext.current = previous }

        // Begin a new page
        pdfContext.beginPDFPage(nil)

        do {
            pdfContext.saveGState()
            defer { pdfContext.restoreGState() }

            pdfContext.textMatrix = .identity
            drawingHandler(pageRect)
        }

        // End the PDF page
        pdfContext.endPDFPage()
        // Close the PDF context
        pdfContext.closePDF()

        return true
    }

    @discardableResult
    public static func draw(attributedString: NSAttributedString,
                            in rect: NSRect) -> Bool
    {
        // center the text in the rect
        let textSize = attributedString.size()
        let textOrigin = NSPoint(
            x: rect.minX + (rect.width - textSize.width) / 2,
            y: rect.minY + (rect.height - textSize.height) / 2
        )

        // draw
        attributedString.draw(in: NSRect(origin: textOrigin, size: textSize))
        return true
    }

    /** Draw image */
    private static func drawImage(size: NSSize,
                                  backgroundColor: NSColor = .white,
                                  drawingHandler: (CGRect) -> Void) -> NSImage?
    {
        let image = NSImage(size: size)
        image.lockFocus()

        let imageRect = NSRect(origin: .zero, size: size)

        // fill background
        backgroundColor.setFill()
        NSBezierPath(rect: imageRect).fill()

        // draw
        drawingHandler(imageRect)

        image.unlockFocus()
        return image
    }

    /** Draw image with CGContext */
    private static func drawImage(size: NSSize,
                                  backgroundColor: NSColor = .white,
                                  drawingHandler: (CGRect, CGContext) -> Void) -> NSImage?
    {
        // create a bitmap-based CGContext
        guard let cgContext = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8, // 8 bits per color component
            bytesPerRow: 0, // Automatically calculated
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue // RGBA format
        )
        else { return nil }

        // switch context
        let previous = NSGraphicsContext.current
        defer { NSGraphicsContext.current = previous }
        NSGraphicsContext.current = NSGraphicsContext(cgContext: cgContext, flipped: false)

        // create rect
        let imageRect = NSRect(origin: .zero, size: size)

        // fill background
        backgroundColor.setFill()
        NSBezierPath(rect: imageRect).fill()

        // draw
        drawingHandler(imageRect, cgContext)

        // create image
        guard let cgImage = cgContext.makeImage() else { return nil }

        return NSImage(cgImage: cgImage, size: size)
    }
}
