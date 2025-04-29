// Copyright 2024-2025 Lie Yan

import OSLog
@_exported import RohanCommon

internal enum Rohan {
  static let version: String = "1.0.0"
  static let domain = "net.satzlich.rohan"
  static let logger = Logger(subsystem: domain, category: "Rohan")

  /// tolerance for layout calculations
  static let tolerance: CGFloat = 1e-6
}
