// Copyright 2024-2025 Lie Yan

import UnicodeMathClass

enum MathAttributes: CommandDeclarationProtocol {
  case mathKind(MathKind)
  case mathLimits(MathLimits)

  var command: String {
    switch self {
    case let .mathKind(kind): return kind.command
    case let .mathLimits(limits): return limits.command
    }
  }

  var mathClass: MathClass? {
    switch self {
    case let .mathKind(kind): return kind.mathClass
    case .mathLimits: return nil
    }
  }

  var limits: Limits? {
    switch self {
    case .mathKind: return nil
    case let .mathLimits(limits): return limits.limits
    }
  }
}

extension MathAttributes {
  static let allCommands: Array<MathAttributes> =
    MathKind.allCommands.map { MathAttributes.mathKind($0) }
    + MathLimits.allCommands.map { MathAttributes.mathLimits($0) }

  private static let _dictionary: [String: MathAttributes] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathAttributes? {
    _dictionary[command]
  }

  static let mathbin = MathAttributes.mathKind(.mathbin)
  static let mathclose = MathAttributes.mathKind(.mathclose)
  static let mathinner = MathAttributes.mathKind(.mathinner)
  static let mathpunct = MathAttributes.mathKind(.mathpunct)
  static let mathop = MathAttributes.mathKind(.mathop)
  static let mathopen = MathAttributes.mathKind(.mathopen)
  static let mathord = MathAttributes.mathKind(.mathord)
  static let mathrel = MathAttributes.mathKind(.mathrel)

  static let _limits = MathAttributes.mathLimits(._limits)
  static let _noLimits = MathAttributes.mathLimits(._noLimits)
}
