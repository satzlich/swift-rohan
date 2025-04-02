// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public protocol CompletionItem: Identifiable {
  var view: NSView { get }
}
