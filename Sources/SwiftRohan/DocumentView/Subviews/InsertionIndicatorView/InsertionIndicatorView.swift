import AppKit
import Foundation

@MainActor
final class InsertionIndicatorView: RohanView {
  private typealias InsertionIndicator = CustomInsertionIndicator

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

    primaryIndicator.displayMode = .hidden
    primaryIndicator.indicatorWidth = indicatorWidth
    addSubview(primaryIndicator)
  }

  func showPrimaryIndicator(_ frame: CGRect) {
    primaryIndicator.frame = frame
    primaryIndicator.displayMode = .automatic
  }

  func hidePrimaryIndicator() {
    primaryIndicator.displayMode = .hidden
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

  /// Starts blinking of the insertion indicators if they are visible.
  func startBlinking() {
    guard primaryIndicator.displayMode != .hidden else { return }
    primaryIndicator.displayMode = .automatic
    secondaryIndicators.forEach { $0.displayMode = .automatic }
  }

  /// Stops blinking of the insertion indicators if they are visible.
  func stopBlinking() {
    guard primaryIndicator.displayMode != .hidden else { return }
    primaryIndicator.displayMode = .visible
    secondaryIndicators.forEach { $0.displayMode = .visible }
  }
}
