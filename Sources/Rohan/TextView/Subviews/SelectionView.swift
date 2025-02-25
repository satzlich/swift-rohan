// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

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

  func addHighlightFrame(_ frame: CGRect) {
    let subview = HighlightView(frame: frame)
    subview.backgroundColor = selectionColor
    addSubview(subview)
  }

  func clearHighlightFrames() {
    subviews.removeAll()
  }
}

private final class HighlightView: RohanView {
  var backgroundColor: NSColor? {
    didSet {
      layer?.backgroundColor = backgroundColor?.cgColor
    }
  }
}
