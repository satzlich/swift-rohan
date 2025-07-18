// Copyright 2024-2025 Lie Yan

import Foundation

struct ContainerTag: OptionSet, CaseIterable, Hashable {
  var rawValue: UInt32

  init(rawValue: UInt32) {
    self.rawValue = rawValue
  }

  /// A container that can hold paragraphs.
  static let paragraphContainer = ContainerTag(rawValue: 1 << 0)

  static let allCases: Array<ContainerTag> = [
    .paragraphContainer
  ]
}
