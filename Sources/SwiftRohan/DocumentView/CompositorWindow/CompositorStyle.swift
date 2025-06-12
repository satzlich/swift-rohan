// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

enum CompositorStyle {
  static let fontSize: CGFloat = 14
  static let iconSize: CGFloat = 18
  static let rowHeight: CGFloat = 24

  static let textFont = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)

  // MARK: - Attributes

  static let baseAttrs: [NSAttributedString.Key: Any] = [.font: textFont]

  static let emphAttrs: [NSAttributedString.Key: Any] =
    [.font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .bold)]

  static func previewAttrs(mathMode: Bool) -> [NSAttributedString.Key: Any] {
    mathMode ? mathPreviewAttrs : previewAttrs
  }

  private static let mathPreviewAttrs: [NSAttributedString.Key: Any] =
    [.font: mathPreviewFont(iconSize)]

  private static let previewAttrs: [NSAttributedString.Key: Any] =
    [.font: NSFont.systemFont(ofSize: iconSize)]

  private static func mathPreviewFont(_ fontSize: CGFloat) -> NSFont {
    if let font = NSFont(name: MathUtils.previewMathFont, size: fontSize) {
      return FontUtils.fontWithCascade(
        baseFont: font, cascadeList: [MathUtils.fallbackMathFont])
    }
    else {
      return NSFont(name: MathUtils.fallbackMathFont, size: fontSize)
        ?? NSFont.systemFont(ofSize: fontSize)
    }
  }

  // MARK: - Metric

  static let leadingPadding: CGFloat = 6
  static let trailingPadding: CGFloat = 6
  static let minFrameWidth: CGFloat = 300

  /// content inset for scroll view
  static let contentInset: CGFloat = 6

  /// padding for icon size difference
  static let iconDiff: CGFloat = 1.5

  /// spacing between text and icon
  static let iconTextSpacing: CGFloat = 7
  private static let unknownError: CGFloat = 2

  static let textFieldXOffset: CGFloat =
    contentInset + leadingPadding + iconSize + iconDiff + iconTextSpacing + unknownError
}
