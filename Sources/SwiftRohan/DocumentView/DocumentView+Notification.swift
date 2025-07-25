import AppKit
import Foundation

extension DocumentView {
  /// Notify user that the operation is rejected.
  func notifyOperationIsRejected() {
    self.window?.shake()
  }
}
