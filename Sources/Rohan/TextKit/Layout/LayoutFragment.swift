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

    /**
     The rectangle the framework uses for tiling the layout fragment inside
     the target layout coordinate system.
     */
    var layoutFragmentFrame: CGRect { get }

    // MARK: - Draw

    /**

     - Parameters:
         - point: the origin
         - context: the rendering context
     */
    func draw(at point: CGPoint, in context: CGContext)
}

public class TextLayoutFragment: LayoutFragment {
    let _textLayoutFragment: NSTextLayoutFragment

    init(textLayoutFragment: NSTextLayoutFragment) {
        self._textLayoutFragment = textLayoutFragment
    }

    public var layoutFragmentFrame: CGRect { _textLayoutFragment.layoutFragmentFrame }

    public func draw(at point: CGPoint, in context: CGContext) {
        _textLayoutFragment.draw(at: point, in: context)
    }
}
