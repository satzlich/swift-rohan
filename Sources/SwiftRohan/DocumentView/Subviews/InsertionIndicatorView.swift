// Copyright 2024-2025 Lie Yan

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

    primaryIndicator.isHidden = true
    primaryIndicator.indicatorWidth = indicatorWidth
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

private final class CustomInsertionIndicator: NSView {
  typealias DisplayMode = NSTextInsertionIndicator.DisplayMode

  private var timer: Timer?

  var color: NSColor = .textInsertionPointColor

  var displayMode: DisplayMode = .automatic {
    didSet {
      _restartCycle()
    }
  }

  var indicatorWidth: CGFloat = 1.0 {
    didSet {
      needsDisplay = true
    }
  }

  override var frame: NSRect {
    didSet {
      _restartCycle()
    }
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    _restartCycle()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    color.set()

    let path = NSBezierPath()
    let xPos = bounds.midX - indicatorWidth / 2

    path.lineCapStyle = .round
    path.lineWidth = indicatorWidth

    path.move(to: NSPoint(x: xPos, y: bounds.minY + indicatorWidth / 2))
    path.line(to: NSPoint(x: xPos, y: bounds.maxY - indicatorWidth / 2))
    path.stroke()
  }

  private func _startBlinking() {
    guard timer == nil else { return }

    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.isHidden.toggle()
      }
    }
  }

  private func _stopBlinking() {
    timer?.invalidate()
    timer = nil
  }

  private func _restartCycle() {
    switch displayMode {
    case .visible:
      isHidden = false
      _stopBlinking()

    case .automatic:
      isHidden = false
      _stopBlinking()
      _startBlinking()

    case .hidden:
      isHidden = true
      _stopBlinking()

    default:
      assertionFailure("Unsupported display mode: \(displayMode)")
      break
    }
  }
}

private final class InsertionIndicatorAdaptor: NSTextInsertionIndicator {
  var indicatorWidth: CGFloat = 1.0 {
    didSet {
      needsDisplay = true
    }
  }
}
