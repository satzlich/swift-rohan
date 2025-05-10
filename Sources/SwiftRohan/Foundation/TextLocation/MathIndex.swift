// Copyright 2024-2025 Lie Yan

public enum MathIndex: Int, Codable, Sendable {
  case lsub = 0
  case lsup = 1
  case nuc = 2
  // attach
  case sub = 3
  case sup = 4
  // fraction
  case num = 5
  case denom = 6
  // radical
  case index = 7
  case radicand = 8
}

extension MathIndex: Comparable {
  public static func < (lhs: MathIndex, rhs: MathIndex) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

extension MathIndex: CaseIterable {}

extension MathIndex: CustomStringConvertible {
  public var description: String {
    switch self {
    case .lsub: return "lsub"
    case .lsup: return "lsup"
    case .nuc: return "nuc"
    case .sub: return "sub"
    case .sup: return "sup"
    case .num: return "num"
    case .denom: return "denom"
    case .index: return "index"
    case .radicand: return "radicand"
    }
  }
}

extension MathIndex {
  static func parse<S: StringProtocol>(_ string: S) -> MathIndex? {
    switch string {
    case "lsub": return .lsub
    case "lsup": return .lsup
    case "nuc": return .nuc
    case "sub": return .sub
    case "sup": return .sup
    case "num": return .num
    case "denom": return .denom
    case "index": return .index
    case "radicand": return .radicand
    default: return nil
    }
  }
}
