// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation

enum TestUtils {
    static func filePath<S>(_ fileName: S, fileExtension: String) -> String?
    where S: StringProtocol {
        precondition(fileExtension.first == ".")

        // get output directory from environment
        guard let baseDir = ProcessInfo().environment["RH_OUTPUT_DIR"]
        else { return nil }

        return "\(baseDir)/\(fileName)\(fileExtension)"
    }

    static func outputPDF(_ fileName: String,
                          _ pageSize: CGSize,
                          _ layoutManager: LayoutManager)
    {
        layoutManager.ensureLayout(delayed: false)
        guard let filePath = TestUtils.filePath(fileName, fileExtension: ".pdf")
        else { return }
        DrawUtils.drawPDF(filePath: filePath, pageSize: pageSize,
                          isFlipped: true)
        { bounds in
            guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
            Self.draw(bounds, layoutManager.textLayoutManager, cgContext)
        }
    }

    static func draw(_ bounds: CGRect,
                     _ textLayoutManager: NSTextLayoutManager,
                     _ cgContext: CGContext)
    {
        cgContext.saveGState()
        defer { cgContext.restoreGState() }

        // fill usage bounds
        cgContext.saveGState()
        cgContext.setFillColor(NSColor.blue.withAlphaComponent(0.05).cgColor)
        cgContext.fill(textLayoutManager.usageBoundsForTextContainer)
        cgContext.restoreGState()

        // draw fragments
        let startLocation = textLayoutManager.documentRange.location
        textLayoutManager.enumerateTextLayoutFragments(from: startLocation) { fragment in
            // draw fragment
            fragment.draw(at: fragment.layoutFragmentFrame.origin, in: cgContext)
            if DebugConfig.DECORATE_LAYOUT_FRAGMENT {
                cgContext.setStrokeColor(NSColor.systemOrange.withAlphaComponent(0.3).cgColor)
                cgContext.stroke(fragment.layoutFragmentFrame)
            }

            // draw text attachments
            for attachmentViewProvider in fragment.textAttachmentViewProviders {
                guard let attachmentView = attachmentViewProvider.view else { continue }
                let attachmentFrame = fragment
                    .frameForTextAttachment(at: attachmentViewProvider.location)
                attachmentView.setFrameOrigin(attachmentFrame.origin)

                cgContext.saveGState()
                cgContext.translateBy(x: fragment.layoutFragmentFrame.origin.x,
                                      y: fragment.layoutFragmentFrame.origin.y)
                cgContext.translateBy(x: attachmentFrame.origin.x,
                                      y: attachmentFrame.origin.y)
                // NOTE: important to negate
                cgContext.translateBy(x: -attachmentView.bounds.origin.x,
                                      y: -attachmentView.bounds.origin.y)
                attachmentView.draw(.infinite)
                cgContext.restoreGState()
            }
            return true // continue
        }
    }
}
