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
    insertionIndicatorView.indicatorWidth = Self.cursorWidth(for: magnification)
  }

  private static func cursorWidth(for magnification: CGFloat) -> CGFloat {
    let baseWidth: CGFloat = 1.0
    let minWidth: CGFloat = 0.5
    let maxWidth: CGFloat = 2.0

    let rawWidth = baseWidth * pow(magnification, 0.7)

    return min(max(rawWidth, minWidth), maxWidth) / magnification
  }
}
