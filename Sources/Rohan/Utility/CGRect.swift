// Copyright 2024-2025 Lie Yan

import Foundation

extension CGRect {
    func centered(in container: CGRect) -> CGRect {
        CGRect(x: container.origin.x + (container.width - width) / 2,
               y: container.origin.y + (container.height - height) / 2,
               width: width,
               height: height)
    }
}
