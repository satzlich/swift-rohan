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
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    func setUp() {
        if DebugConfig.DEBUG_CONTENT_VIEW {
            layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.05).cgColor
        }
    }
}
