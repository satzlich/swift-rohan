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

protocol RhLayoutFragment {
    var layoutFragmentFrame: CGRect { get }
    func draw(at point: CGPoint, in context: CGContext)
}

public class RhTextLayoutFragment: RhLayoutFragment {
    let _textLayoutFragment: NSTextLayoutFragment

    init(textLayoutFragment: NSTextLayoutFragment) {
        self._textLayoutFragment = textLayoutFragment
    }

    public var layoutFragmentFrame: CGRect { _textLayoutFragment.layoutFragmentFrame }

    public func draw(at point: CGPoint, in context: CGContext) {
        _textLayoutFragment.draw(at: point, in: context)
    }
}

