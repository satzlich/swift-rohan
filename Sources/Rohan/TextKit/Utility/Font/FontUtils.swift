// Copyright 2024-2025 Lie Yan

import AppKit

enum FontUtils {
  static func fontWithCascade(
    baseFont: NSFont, cascadeList: [String]
  ) -> NSFont {
    guard let familyName = baseFont.familyName
    else { return baseFont }

    let cascadeList = cascadeList.map { familyName in
      NSFontDescriptor(fontAttributes: [.family: familyName])
    }

    let attributes: [NSFontDescriptor.AttributeName: Any] = [
      .family: familyName,
      .cascadeList: cascadeList,
    ]

    let augmented = baseFont.fontDescriptor.addingAttributes(attributes)
    return NSFont(descriptor: augmented, size: baseFont.pointSize) ?? baseFont
  }
}
