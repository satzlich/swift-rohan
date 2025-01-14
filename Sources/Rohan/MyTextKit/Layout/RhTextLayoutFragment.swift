// Copyright 2024-2025 Lie Yan

import Foundation
import AppKit

/*

 text layout
 |---[text layout fragment]

 text layout fragment
 |---[text line fragment]

 text line fragment
 |---[text segment]

 text segment <- (proper) text segment | math fragment

 */

public class RhTextLayoutFragment { }

public class RhMathFragment {
    let attributedString: NSAttributedString

    init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
}
