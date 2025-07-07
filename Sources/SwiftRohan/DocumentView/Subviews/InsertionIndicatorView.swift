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

final class CustomInsertionIndicator: NSView {
  typealias DisplayMode = NSTextInsertionIndicator.DisplayMode

  var color: NSColor = .textInsertionPointColor {
    didSet {
      needsDisplay = true
    }
  }

  var indicatorWidth: CGFloat = 1.0 {
    didSet {
      needsDisplay = true
    }
  }

  var displayMode: DisplayMode = .automatic {
    didSet {
      _restartCycle()
    }
  }

  override var frame: NSRect {
    didSet {
      _restartCycle()
    }
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    color.set()

    let path = NSBezierPath()
    path.lineCapStyle = .round
    path.lineWidth = indicatorWidth

    let x0 = bounds.midX
    let halfWidth = indicatorWidth / 2
    let y0 = bounds.minY + halfWidth
    let y1 = bounds.maxY - halfWidth
    path.move(to: NSPoint(x: x0, y: y0))
    path.line(to: NSPoint(x: x0, y: y1))
    path.stroke()
  }

  private func _startBlinking() {
    guard _timer == nil else { return }

    _timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.isHidden.toggle()
      }
    }
  }

  private func _stopBlinking() {
    _timer?.invalidate()
    _timer = nil
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

  // MARK: - State

  private var _timer: Timer?

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    _restartCycle()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private final class InsertionIndicatorAdaptor: NSTextInsertionIndicator {
  var indicatorWidth: CGFloat = 1.0 {
    didSet {
      needsDisplay = true
    }
  }
}
