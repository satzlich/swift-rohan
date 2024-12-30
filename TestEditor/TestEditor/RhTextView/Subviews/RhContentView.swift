// Copyright 2024 Lie Yan

import AppKit
import Foundation

/**

 ```
 RhContentView
    |---RhTextLayoutFragmentView *
 ```
 */
final class RhContentView: RhView {
    var backgroundColor: NSColor? {
        didSet {
            layer?.backgroundColor = backgroundColor?.cgColor
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    func setUp() {
        if backgroundColor == nil,
           DebugConfig.DEBUG_CONTENT_VIEW
        {
            backgroundColor = .white
        }
    }
}
