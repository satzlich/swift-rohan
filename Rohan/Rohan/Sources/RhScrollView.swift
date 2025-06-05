// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import SwiftRohan

class RhScrollView: NSScrollView {
  weak var scrollDelegate: ScrollViewDelegate?

  override func magnify(with event: NSEvent) {
    super.magnify(with: event)
    scrollDelegate?.scrollView(self, didChangeMagnification: ())
  }
}
