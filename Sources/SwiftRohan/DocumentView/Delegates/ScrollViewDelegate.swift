import AppKit
import Foundation

public protocol ScrollViewDelegate: AnyObject {
  func scrollView(_ scrollView: NSScrollView, didChangeMagnification: Void)
}
