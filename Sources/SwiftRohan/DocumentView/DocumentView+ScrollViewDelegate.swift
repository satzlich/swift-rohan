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
    insertionIndicatorView.indicatorWidth = 2 / magnification
  }
}
