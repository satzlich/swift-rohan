// Copyright 2024-2025 Lie Yan

import LatexParser
import UnicodeMathClass

enum MathAttributes: CommandDeclarationProtocol {
  case mathKind(MathKind)
  case mathLimits(MathLimits)
  case combo(MathKind, MathLimits)

  var command: String {
    switch self {
    case let .mathKind(kind): return kind.command
    case let .mathLimits(limits): return limits.command
    case let .combo(kind, limits): return "_\(kind.command)_\(limits.command)"
    }
  }

  var source: CommandSource {
    switch self {
    case let .mathKind(kind): return kind.source
    case let .mathLimits(limits): return limits.source
    case .combo: return .customExtension
    }
  }

  var tag: CommandTag {
    switch self {
    case .mathKind(let kind): return kind.tag
    case .mathLimits(let limits): return limits.tag
    case .combo(let kind, let limits):
      assert(kind.tag == limits.tag)
      return kind.tag
    }
  }

  var mathClass: MathClass? {
    switch self {
    case let .mathKind(kind): return kind.mathClass
    case .mathLimits: return nil
    case let .combo(kind, _): return kind.mathClass
    }
  }

  var limits: Limits? {
    switch self {
    case .mathKind: return nil
    case let .mathLimits(limits): return limits.limits
    case let .combo(_, limits): return limits.limits
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
