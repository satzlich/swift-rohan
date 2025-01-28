// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class MathListLayoutAttachmentViewProvider: NSTextAttachmentViewProvider {
    @MainActor
    override public func loadView() {
        guard let attachment = textAttachment as? MathListLayoutAttachment
        else { return }
        view = MathListLayoutView(attachment.fragment)
    }

    override public func attachmentBounds(
        for attributes: [NSAttributedString.Key: Any],
        location: any NSTextLocation,
        textContainer: NSTextContainer?,
        proposedLineFragment: CGRect,
        position: CGPoint
    ) -> CGRect {
        guard let view else { return .zero }
        return view.bounds
    }
}

public class MathListLayoutAttachment: NSTextAttachment {
    let fragment: MathListLayoutFragment

    init(_ fragment: MathListLayoutFragment) {
        self.fragment = fragment
        super.init(data: nil, ofType: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewProvider(
        for parentView: NSView?,
        location: any NSTextLocation,
        textContainer: NSTextContainer?
    ) -> NSTextAttachmentViewProvider? {
        let viewProvider = MathListLayoutAttachmentViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
        viewProvider.tracksTextAttachmentViewBounds = true
        return viewProvider
    }

    /** Necessary to stop drawing a placeholder image */
    override public func image(forBounds imageBounds: CGRect,
                               textContainer: NSTextContainer?,
                               characterIndex charIndex: Int) -> NSImage?
    {
        NSImage()
    }
}

final class MathListLayoutView: NSView {
    let fragment: MathListLayoutFragment

    init(_ fragment: MathListLayoutFragment) {
        self.fragment = fragment
        super.init(frame: CGRect(origin: .zero, size: fragment.layoutFragmentFrame.size))
        self.bounds = CGRect(x: 0, y: -fragment.descent,
                             width: fragment.width, height: fragment.height)
    }

    override var isFlipped: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let cgContext = NSGraphicsContext.current?.cgContext else { return }

        let fragmentOrigin = CGPoint(x: frame.origin.x,
                                     y: frame.origin.y + fragment.ascent)
        fragment.draw(at: fragmentOrigin, in: cgContext)
    }
}
