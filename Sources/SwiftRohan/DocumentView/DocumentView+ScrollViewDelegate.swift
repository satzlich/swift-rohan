// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView: ScrollViewDelegate {
  public func scrollView(
    _ scrollView: NSScrollView, didChangeMagnification magnification: CGFloat
  ) {
    setIndicatorWidth(magnification)
  }

  private func setIndicatorWidth(_ magnification: CGFloat) {
    let mag = max(magnification, 0.1)
    insertionIndicatorView.indicatorWidth = 2 / mag
  }
}
