// Copyright 2024-2025 Lie Yan

import Foundation

struct MathLimits: CommandDeclarationProtocol {
  let limits: Limits

  /// "_" inidicates it is not exported.
  var command: String {
    switch limits {
    case .always:
      return "_limits"
    case .never:
      return "_nolimits"
    case .display:
      preconditionFailure()
    }
  }

  init(_ limits: Limits) {
    self.limits = limits
  }
}

extension MathLimits {
  static let allCommands: [MathLimits] = [
    _limits,
    _noLimits,
  ]

  private static let _dictionary: [String: MathLimits] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathLimits? {
    _dictionary[command]
  }

  static let _limits: MathLimits = MathLimits(.always)
  static let _noLimits: MathLimits = MathLimits(.never)
}
