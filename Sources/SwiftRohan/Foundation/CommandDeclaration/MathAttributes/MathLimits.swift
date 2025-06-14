// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

struct MathLimits: CommandDeclarationProtocol {
  let limits: Limits

  /// "_" inidicates it is not exported.
  var command: String {
    switch limits {
    case .always:
      return "limits"
    case .never:
      return "nolimits"
    case .display:
      assertionFailure("Display limits should not be used in a command.")
      return "displaylimits"
    }
  }

  var tag: CommandTag { .null }
  var source: CommandSource { .customExtension }

  init(_ limits: Bool) {
    self.limits = limits ? .always : .never
  }
}

extension MathLimits {
  static let allCommands: Array<MathLimits> = [
    limits,
    nolimits,
  ]

  private static let _dictionary: Dictionary<String, MathLimits> =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathLimits? {
    _dictionary[command]
  }

  static let limits: MathLimits = MathLimits(true)
  static let nolimits: MathLimits = MathLimits(false)
}
