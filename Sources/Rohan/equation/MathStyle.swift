// Copyright 2024 Lie Yan

/**
 An extrinsic property of a math formula.

 # Note
 The relation between math style and font size is as follows:

 | Display Style   | Font Size          |
 |-----------------|--------------------|
 | Display, Text   | text size          |
 | Script          | script size        |
 | ScriptScript    | scriptscript size  |
 */
public enum MathStyle: Equatable, Hashable {
    case Display
    case Text
    case Script
    case ScriptScript
}
