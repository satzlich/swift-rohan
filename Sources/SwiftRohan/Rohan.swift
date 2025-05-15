// Copyright 2024-2025 Lie Yan

import OSLog
import _RopeModule

internal enum Rohan {
  static let domain = "net.satzlich.rohan"
  static let logger = Logger(subsystem: domain, category: "Rohan")

  /// tolerance for layout calculations
  static let tolerance: CGFloat = 1e-6
}

typealias RhString = BigString
typealias RhSubstring = BigSubstring
