import AppKit

enum FontUtils {
  /// Augment a font with a cascade list.
  static func fontWithCascade(baseFont: NSFont, cascadeList: Array<String>) -> NSFont {
    guard let familyName = baseFont.familyName else { return baseFont }

    let cascadeList = cascadeList.map { familyName in
      NSFontDescriptor(fontAttributes: [.family: familyName])
    }

    let attributes: Dictionary<NSFontDescriptor.AttributeName, Any> = [
      .family: familyName,
      .cascadeList: cascadeList,
    ]

    let augmented = baseFont.fontDescriptor.addingAttributes(attributes)
    return NSFont(descriptor: augmented, size: baseFont.pointSize) ?? baseFont
  }
}
