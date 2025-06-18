// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView: @preconcurrency ScrollViewDelegate {
  public func scrollView(_ scrollView: NSScrollView, didChangeMagnification: Void) {
    let magnification = scrollView.magnification
    insertionIndicatorView.indicatorWidth = Self.cursorWidth(for: magnification)
  }

  /// Calculate the cursor width based on the magnification factor.
  internal static func cursorWidth(for magnification: CGFloat) -> CGFloat {
    let baseWidth: CGFloat = 1.0
    let minWidth: CGFloat = 0.5
    let maxWidth: CGFloat = 3.0

    let rawWidth = baseWidth * pow(magnification, 0.7)

    return min(max(rawWidth, minWidth), maxWidth) / magnification
  }
}
