// Copyright 2024 Lie Yan

import AppKit
import Foundation

final class RhContentView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    func setUp() {
        wantsLayer = true
        clipsToBounds = true
    }

    override var isFlipped: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }
}
