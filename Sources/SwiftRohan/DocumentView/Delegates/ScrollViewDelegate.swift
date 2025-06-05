// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public protocol ScrollViewDelegate: AnyObject {
  func scrollView(_ scrollView: NSScrollView, didChangeMagnification: Void)
}
