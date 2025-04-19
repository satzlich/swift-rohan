// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public protocol DocumentViewDelegate: AnyObject {
  func documentDidChange(_ documentView: DocumentView)
}
