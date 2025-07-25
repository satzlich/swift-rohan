import AppKit
import Foundation

enum CompositorStyle {
  static let fontSize: CGFloat = 14
  static let iconSize: CGFloat = 18
  static let rowHeight: CGFloat = 24

  nonisolated(unsafe) static let textFont =
    NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)

  // MARK: - Attributes

  nonisolated(unsafe) static let baseAttrs: Dictionary<NSAttributedString.Key, Any> =
    [.font: textFont]

  nonisolated(unsafe) static let emphAttrs: Dictionary<NSAttributedString.Key, Any> =
    [.font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .bold)]

  static func previewAttrs(mathMode: Bool) -> Dictionary<NSAttributedString.Key, Any> {
    mathMode ? mathPreviewAttrs : previewAttrs
  }

  nonisolated(unsafe) private static let mathPreviewAttrs:
    Dictionary<NSAttributedString.Key, Any> = [.font: mathPreviewFont(iconSize)]

  nonisolated(unsafe) private static let previewAttrs:
    Dictionary<NSAttributedString.Key, Any> = [.font: NSFont.systemFont(ofSize: iconSize)]

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
