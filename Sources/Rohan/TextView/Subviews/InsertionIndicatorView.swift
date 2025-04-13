// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class InsertionIndicatorView: RohanView {
  private let primaryIndicator: NSTextInsertionIndicator
  private var secondaryIndicators: [NSTextInsertionIndicator]

  override init(frame frameRect: CGRect) {
    self.primaryIndicator = NSTextInsertionIndicator()
    self.secondaryIndicators = []
    super.init(frame: frameRect)

    primaryIndicator.isHidden = true
    addSubview(primaryIndicator)
  }

  func showPrimaryIndicator(_ frame: CGRect) {
    primaryIndicator.frame = frame
    primaryIndicator.isHidden = false
  }

  func hidePrimaryIndicator() {
    primaryIndicator.isHidden = true
  }

  func addSecondaryIndicator(_ frame: CGRect) {
    let subview = NSTextInsertionIndicator(frame: frame)
    subview.color = primaryIndicator.color.withAlphaComponent(0.5)
    secondaryIndicators.append(subview)
    addSubview(subview)
  }

  func clearSecondaryIndicators() {
    secondaryIndicators.forEach { $0.removeFromSuperview() }
    secondaryIndicators.removeAll()
  }

  /// Stops blinking of the insertion indicators if they are visible.
  func stopBlinking() {
    if !primaryIndicator.isHidden {
      primaryIndicator.displayMode = .visible
      secondaryIndicators.forEach { $0.displayMode = .visible }
    }
  }

  /// Starts blinking of the insertion indicators if they are visible.
  func startBlinking() {
    if !primaryIndicator.isHidden {
      primaryIndicator.displayMode = .automatic
      secondaryIndicators.forEach { $0.displayMode = .automatic }
    }
  }
}
