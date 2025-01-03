// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSResponder {
    #if DEBUG
    var responderChain: [NSResponder] {
        Array(sequence(first: self, next: \.nextResponder))
    }
    #endif
}
