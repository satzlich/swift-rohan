// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

protocol MathLayoutFragment: LayoutFragment, MathFragment {
    // MARK: - Frame

    func setFrameOrigin(_ origin: CGPoint)

    // MARK: Length

    /**
     Length perceived by the layout context.
     - Note: `layoutLength` can differ from the sum over its children.
     */
    var layoutLength: Int { get }
}
