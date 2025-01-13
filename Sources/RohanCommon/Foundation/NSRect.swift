// Copyright 2024-2025 Lie Yan

import Foundation

extension NSRect {
    /** center the rect in the container */
    public func centered(in container: NSRect) -> NSRect {
        NSRect(x: container.origin.x + (container.width - width) / 2,
               y: container.origin.y + (container.height - height) / 2,
               width: width,
               height: height)
    }
}
