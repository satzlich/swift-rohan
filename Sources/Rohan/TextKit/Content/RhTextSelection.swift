// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/** Text selection. */
public struct RhTextSelection { // text selection is an insertion point
    public var textRanges: [RhTextRange] { preconditionFailure() }

    internal var nsTextSelection: NSTextSelection?
}
