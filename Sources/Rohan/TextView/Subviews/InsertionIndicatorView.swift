// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class InsertionIndicatorView: RohanView {
  private let insertionIndicator: NSTextInsertionIndicator

  override init(frame frameRect: CGRect) {
    self.insertionIndicator = NSTextInsertionIndicator()
    super.init(frame: frameRect)

    insertionIndicator.isHidden = true
    addSubview(insertionIndicator)
  }

  func showInsertionIndicator(_ frame: CGRect) {
    insertionIndicator.frame = frame
    insertionIndicator.isHidden = false
  }

  func hideInsertionIndicator() {
    insertionIndicator.isHidden = true
  }
}
