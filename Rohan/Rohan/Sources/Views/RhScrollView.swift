import AppKit
import Foundation
import SwiftRohan

final class RhScrollView: NSScrollView {
  weak var scrollDelegate: ScrollViewDelegate?

  override func magnify(with event: NSEvent) {
    super.magnify(with: event)
    scrollDelegate?.scrollView(self, didChangeMagnification: ())
  }
}
