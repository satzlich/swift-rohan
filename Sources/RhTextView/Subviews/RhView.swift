// Copyright 2024 Lie Yan

import AppKit
import Foundation

open class RhView: NSView {
    var backgroundColor: NSColor? {
        didSet {
            layer?.backgroundColor = backgroundColor?.cgColor
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        wantsLayer = true
        clipsToBounds = true
    }

    override public var isFlipped: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }
}
