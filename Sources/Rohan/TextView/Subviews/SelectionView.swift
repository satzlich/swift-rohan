// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

enum HighlightType {
  case selection
  case highlight
}

/**
 ```
 SelectionView
 └ HighlightView *
 ```
 */
final class SelectionView: RohanView {
  var selectionColor: NSColor? = NSColor.selectedTextBackgroundColor {
    didSet {
      for subview in subviews {
        (subview as? HighlightView)?.backgroundColor = selectionColor
      }
    }
  }

  func addHighlightFrame(_ frame: CGRect, type: HighlightType = .selection) {
    guard frame.size.width > 0, frame.size.height > 0 else { return }
    let subview = HighlightView(frame: frame)
    subview.backgroundColor = Self.getColor(for: type)
    addSubview(subview)
  }

  func clearHighlightFrames() {
    subviews.removeAll()
  }

  /// Returns the background color for the given highlight type.
  private static func getColor(for type: HighlightType) -> NSColor {
    switch type {
    case .selection:
      return NSColor.selectedTextBackgroundColor
    case .highlight:
      return NSColor.selectedTextBackgroundColor.withAlphaComponent(0.33)
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
