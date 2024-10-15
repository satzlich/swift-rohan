// Copyright 2024 Lie Yan

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
public enum MathStyle: Equatable, Hashable {
    case display
    case text
    case script
    case scriptScript
}
