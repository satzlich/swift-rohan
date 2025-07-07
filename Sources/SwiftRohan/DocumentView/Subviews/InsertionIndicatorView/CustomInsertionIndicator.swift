// Copyright 2024-2025 Lie Yan

import AppKit

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

    @unknown default:
      assertionFailure("Unknown display mode: \(displayMode)")
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
