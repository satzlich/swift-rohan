// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class InsertionIndicatorView: RohanView {
  private typealias InsertionIndicator =
    TextInsertionIndicator  // alternative: NSTextInsertionIndicator

  private let primaryIndicator: InsertionIndicator
  private var secondaryIndicators: Array<InsertionIndicator>

  /// The width of the vertical indicator
  var indicatorWidth: CGFloat = 1.0 {
    didSet {
      primaryIndicator.width = indicatorWidth
      secondaryIndicators.forEach { $0.width = indicatorWidth }
      needsDisplay = true
    }
  }

  override init(frame frameRect: CGRect) {
    self.primaryIndicator = InsertionIndicator()
    self.secondaryIndicators = []
    super.init(frame: frameRect)

    primaryIndicator.isHidden = true
    primaryIndicator.width = indicatorWidth
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
    subview.width = indicatorWidth
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

internal final class TextInsertionIndicator: NSView {
  typealias DisplayMode = NSTextInsertionIndicator.DisplayMode

  /// The current display mode
  var displayMode: DisplayMode = .automatic {
    didSet {
      updateVisibility()
    }
  }

  /// The color of the indicator (defaults to system insertion point color)
  var color: NSColor = .textInsertionPointColor {
    didSet {
      needsDisplay = true
    }
  }

  /// The width of the vertical indicator
  var width: CGFloat = 1.0 {
    didSet {
      needsDisplay = true
    }
  }

  private var blinkTimer: Timer?
  private var shouldDraw: Bool = true

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    commonInit()
    startBlinking()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
    startBlinking()
  }

  convenience init() {
    self.init(frame: .zero)
  }

  private func commonInit() {
    self.wantsLayer = true
    self.layer?.masksToBounds = false
    updateVisibility()
  }

  override var frame: NSRect {
    didSet {
      if displayMode == .automatic {
        restartBlinking()
      }
      needsDisplay = true
    }
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    guard shouldDraw else { return }

    color.set()

    let path = NSBezierPath()
    let xPos = bounds.midX - width / 2

    path.lineCapStyle = .round
    path.lineWidth = width

    path.move(to: NSPoint(x: xPos, y: bounds.minY + width / 2))
    path.line(to: NSPoint(x: xPos, y: bounds.maxY - width / 2))
    path.stroke()
  }

  private func updateVisibility() {
    stopBlinking()

    switch displayMode {
    case .automatic:
      isHidden = false
      startBlinking()
    case .hidden:
      isHidden = true
    case .visible:
      isHidden = false
      shouldDraw = true
    @unknown default:
      assertionFailure("Unknown display mode: \(displayMode)")
      isHidden = false
      shouldDraw = true
    }

    needsDisplay = true
  }

  private func startBlinking() {
    guard displayMode == .automatic else { return }

    stopBlinking()
    shouldDraw = true
    blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {
      [weak self] _ in
      guard let self = self else { return }
      self.shouldDraw = !self.shouldDraw
      self.needsDisplay = true
    }
  }

  private func restartBlinking() {
    shouldDraw = true
    needsDisplay = true
    startBlinking()
  }

  private func stopBlinking() {
    blinkTimer?.invalidate()
    blinkTimer = nil
    shouldDraw = true
  }

  deinit {
    stopBlinking()
  }
}
