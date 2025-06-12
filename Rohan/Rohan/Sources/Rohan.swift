// Copyright 2024-2025 Lie Yan

import Foundation
import OSLog

enum Rohan {
  static let domain = "net.satzlich.rohan"
  static let logger = Logger(subsystem: domain, category: "Rohan")
}

extension CGRect {
  var center: CGPoint { CGPoint(x: midX, y: midY) }
}
