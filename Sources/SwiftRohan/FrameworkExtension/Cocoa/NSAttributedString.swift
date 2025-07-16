// Copyright 2024-2025 Lie Yan

import AppKit

extension NSAttributedString.Key {
  static let rhFirstLineHeadIndent = NSAttributedString.Key("rhFirstLineHeadIndent")  // CGFloat
  static let rhHeadIndent = NSAttributedString.Key("rhHeadIndent")  // CGFloat
  static let rhItemMarker = NSAttributedString.Key("rhItemMarker")  // NSAttributedString
  static let rhListLevel = NSAttributedString.Key("rhListLevel")  // Int
  static let rhTextAlignment = NSAttributedString.Key("rhTextAlignment")  // NSTextAlignment

  static let rhEquationNumber = NSAttributedString.Key("rhEquationNumber")  // NSAttributedString
  static let rhHorizontalBounds = NSAttributedString.Key("rhHorizontalBounds")  // HorizontalBounds

  static let rhVerticalRibbon = NSAttributedString.Key("rhVerticalRibbon")  // NSColor
}
