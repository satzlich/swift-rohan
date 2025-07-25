import AppKit
import Foundation

enum HighlightType {
  /// Selection highlight.
  case selection
  /// Visual delimiter highlight.
  case delimiter(level: Int = 0)
}

/**
 ```
 SelectionView
 └ HighlightView *
 ```
 */
final class SelectionView: RohanView {
  /// Add a highlight frame to the view with the given type.
  func addHighlightFrame(_ frame: CGRect, type: HighlightType = .selection) {
    guard frame.size.width > 0, frame.size.height > 0 else { return }
    let subview = HighlightView(frame: frame)
    subview.backgroundColor = Self.backgroundColor(for: type)
    addSubview(subview)
  }

  func clearHighlightFrames() {
    subviews.removeAll()
  }

  /// Returns the background color for the given highlight type.
  private static func backgroundColor(for type: HighlightType) -> NSColor {
    switch type {
    case .selection:
      return NSColor.selectedTextBackgroundColor
    case .delimiter(let level):
      if level % 2 == 0 {
        return NSColor.selectedTextBackgroundColor.withAlphaComponent(0.5)
      }
      else {
        return NSColor.unemphasizedSelectedTextBackgroundColor.withAlphaComponent(0.5)
      }
    }
  }
}

private final class HighlightView: RohanView {
  var backgroundColor: NSColor? {
    didSet {
      layer?.backgroundColor = backgroundColor?.cgColor
    }
  }
}
