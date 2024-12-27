// Copyright 2024 Lie Yan

import Cocoa
import Foundation

final class RhTextLayoutFragmentView: NSView {
    var layoutFragment: NSTextLayoutFragment {
        didSet {
            needsDisplay = true
            needsLayout = true
        }
    }

    override var isFlipped: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    init(layoutFragment: NSTextLayoutFragment, frame: CGRect) {
        self.layoutFragment = layoutFragment
        super.init(frame: frame)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp() {
        wantsLayer = true
        clipsToBounds = false // allow overdraw invisible characters

        // debug border
        do {
            layer?.backgroundColor = NSColor.systemOrange.withAlphaComponent(0.05).cgColor
            layer?.borderColor = NSColor.systemOrange.cgColor
            layer?.borderWidth = 0.5
        }

        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        context.saveGState()
        layoutFragment.draw(at: .zero, in: context)
        context.restoreGState()
    }
}
