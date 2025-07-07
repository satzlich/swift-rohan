// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

@MainActor
final class InsertionIndicatorView: RohanView {
  private typealias InsertionIndicator = CustomWidthInsertionIndicator

  private let primaryIndicator: InsertionIndicator
  private var secondaryIndicators: Array<InsertionIndicator>

  /// The width of the vertical indicator
  var indicatorWidth: CGFloat = 1.0 {
    didSet {
      primaryIndicator.indicatorWidth = indicatorWidth
      secondaryIndicators.forEach { $0.indicatorWidth = indicatorWidth }
      needsDisplay = true
    }
  }

  override init(frame frameRect: CGRect) {
    self.primaryIndicator = InsertionIndicator()
    self.secondaryIndicators = []
    super.init(frame: frameRect)

    assert(clipsToBounds == false)

    primaryIndicator.isHidden = true
    primaryIndicator.indicatorWidth = indicatorWidth
    addSubview(primaryIndicator)
  }

  func showPrimaryIndicator(_ frame: CGRect) {
    primaryIndicator.frame = frame
    primaryIndicator.isHidden = false

    // restart blinking cycle.
    primaryIndicator.displayMode = primaryIndicator.displayMode
  }

  func hidePrimaryIndicator() {
    primaryIndicator.isHidden = true
  }

  func addSecondaryIndicator(_ frame: CGRect) {
    let subview = InsertionIndicator(frame: frame)
    subview.indicatorWidth = indicatorWidth
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

final class CustomWidthInsertionIndicator: NSTextInsertionIndicator {
  var indicatorWidth: CGFloat = 1.0 {
    didSet {
      needsDisplay = true
    }
  }
}
