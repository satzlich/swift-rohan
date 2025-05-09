// Copyright 2024-2025 Lie Yan

import AppKit

enum SFSymbolUtils {
  /// Create a text field with a system symbol and specified font size.
  @MainActor
  static func textField(for symbol: String, _ fontSize: CGFloat) -> NSTextField {
    let textField = NSTextField(labelWithString: "")
    textField.font = NSFont.systemFont(ofSize: fontSize)  // Set font size here

    let symbolConfig = NSImage.SymbolConfiguration(pointSize: fontSize, weight: .regular)
    if let symbolImage = NSImage(
      systemSymbolName: symbol,
      accessibilityDescription: nil
    )?.withSymbolConfiguration(symbolConfig) {
      let attachment = NSTextAttachment()
      attachment.image = symbolImage

      let attributedString = NSAttributedString(attachment: attachment)
      textField.attributedStringValue = attributedString
    }

    return textField
  }
}
