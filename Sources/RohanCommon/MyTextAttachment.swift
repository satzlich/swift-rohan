// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class MyTextAttachmentViewProvider: NSTextAttachmentViewProvider {
    override public func loadView() {
        // super.loadView()

        guard let attachment = textAttachment as? MyTextAttachment else { return }

        let myView = MyView(width: attachment.width,
                            ascent: attachment.ascent, descent: attachment.descent)
        view = myView
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

public class MyTextAttachment: NSTextAttachment {
    var width: CGFloat
    var ascent: CGFloat
    var descent: CGFloat

    public init(width: CGFloat = 20, ascent: CGFloat = 20, descent: CGFloat = 0) {
        self.width = width
        self.ascent = ascent
        self.descent = descent
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
        let viewProvider = MyTextAttachmentViewProvider(
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

public class MyView: NSView {
    var width: CGFloat {
        didSet {
            bounds.size.width = width
        }
    }

    var ascent: CGFloat {
        didSet {
            bounds.size.height = ascent + descent
        }
    }

    var descent: CGFloat {
        didSet {
            bounds.origin.y = -descent
            bounds.size.height = ascent + descent
        }
    }

    init(width: CGFloat, ascent: CGFloat, descent: CGFloat) {
        self.width = width
        self.ascent = ascent
        self.descent = descent
        super.init(frame: NSRect(x: 0, y: 0,
                                 width: width, height: ascent + descent))
        bounds.origin.y = -descent
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_ dirtyRect: NSRect) {
        NSColor.orange.withAlphaComponent(0.3).setStroke()
        NSBezierPath(rect: frame).stroke()
    }
}
