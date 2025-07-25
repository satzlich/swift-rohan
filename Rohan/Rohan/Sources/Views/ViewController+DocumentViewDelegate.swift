import Foundation
import SwiftRohan

extension ViewController: DocumentViewDelegate {
  func documentDidChange(_ documentView: DocumentView) {
    if let document = self.view.window?.windowController?.document as? Document {
      // mark as edited
      document.updateChangeCount(.changeDone)
    }
  }
}
