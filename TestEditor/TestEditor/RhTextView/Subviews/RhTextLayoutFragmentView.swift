// Copyright 2024 Lie Yan

import Cocoa
import Foundation

final class RhTextLayoutFragmentView: RhView {
    var layoutFragment: NSTextLayoutFragment {
        didSet {
            needsLayout = true
            needsDisplay = true
        }
    }

    init(layoutFragment: NSTextLayoutFragment, frame: CGRect) {
        self.layoutFragment = layoutFragment
        super.init(frame: frame)

        if DebugConfig.DEBUG_LAYOUT_FRAGMENT {
            layer?.backgroundColor = NSColor.systemOrange.withAlphaComponent(0.05).cgColor
            layer?.borderColor = NSColor.systemOrange.cgColor
            layer?.borderWidth = 0.5
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
