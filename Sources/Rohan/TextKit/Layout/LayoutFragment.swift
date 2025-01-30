// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/*

 text layout
 |---[text layout fragment]

 text layout fragment
 |---[text line fragment]

 text line fragment
 |---[text segment]

 text segment <- (proper) text segment | math fragment

 */

public protocol LayoutFragment {
    // MARK: - Frame

    /** The rectangle the framework uses for tiling the layout fragment inside
     the target layout coordinate system. */
    var layoutFragmentFrame: CGRect { get }

    // MARK: - Draw

    func draw(at point: CGPoint, in context: CGContext)
}
