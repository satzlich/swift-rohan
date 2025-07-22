// Copyright 2024-2025 Lie Yan

import Cocoa
import SwiftRohan

extension ViewController: NSMenuItemValidation {
  func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    switch menuItem.action {
    case #selector(zoomIn(_:)):
      return scrollView.magnification < scrollView.maxMagnification
    case #selector(zoomOut(_:)):
      return scrollView.magnification > scrollView.minMagnification
    case #selector(zoomImageToActualSize(_:)):
      return abs(scrollView.magnification - 1.0) > 0.01
    default:
      return true
    }
  }
}
