import Foundation
import LatexParser
import UnicodeMathClass

enum MathKind: String, Codable, CaseIterable, CommandDeclarationProtocol {
  case mathbin
  case mathclose
  case mathinner
  case mathop
  case mathopen
  case mathord
  case mathpunct
  case mathrel

  var command: String { rawValue }
  var tag: CommandTag { self == .mathop ? .mathOperator : .null }
  var source: CommandSource { .preBuilt }
  static var allCommands: Array<MathKind> { allCases }
}

extension MathKind {
  private static let _dictionary: Dictionary<String, MathKind> =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathKind? {
    _dictionary[command]
  }
}

extension MathKind {
  var mathClass: MathClass {
    switch self {
    case .mathbin: .Binary
    case .mathclose: .Closing
    case .mathinner:
      // override Special for Inner. See also `resolveSpacing(_:_:_:)`.
      .Special
    case .mathop: .Large
    case .mathopen: .Opening
    case .mathord: .Normal
    case .mathpunct: .Punctuation
    case .mathrel: .Relation
    }
  }
}
