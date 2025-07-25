import Foundation
import LatexParser

struct MathLimits: CommandDeclarationProtocol {
  private let _limits: Bool

  var limits: Limits { _limits ? .always : .never }

  var command: String { _limits ? "limits" : "nolimits" }

  var tag: CommandTag { .null }
  var source: CommandSource { .preBuilt }

  init(_ limits: Bool) {
    self._limits = limits
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
