import AppKit
import Foundation

public protocol DocumentViewDelegate: AnyObject {
  func documentDidChange(_ documentView: DocumentView)
}
