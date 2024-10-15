// Copyright 2024 Lie Yan

import Foundation

/**
 An extrinsic property of a math formula.

 # Note
 The relationship between math style and font size is as follows:

 | Math Style      | Font Size          |
 |-----------------|--------------------|
 | display, text   | text size          |
 | script          | script size        |
 | scriptScript    | scriptScript size  |
 */
public enum MathStyle {
    case display
    case text
    case script
    case scriptScript
}

public enum MathVariant {
    /// Default variant.
    case serif

    case sans
    case frak
    case mono
    case bb
    case cal
}
