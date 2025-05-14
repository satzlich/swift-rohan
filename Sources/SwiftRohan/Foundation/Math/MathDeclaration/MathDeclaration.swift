// Copyright 2024-2025 Lie Yan

import Foundation

protocol MathDeclarationProtocol: Codable, Sendable {
  var command: String { get }
  static var predefinedCases: [Self] { get }
}

enum MathDeclaration: MathDeclarationProtocol {
  case accent(MathAccent)
  case array(MathArray)
  case genfrac(MathGenFrac)
  case operator_(MathOperator)
  case overSpreader(MathOverSpreader)
  case symbol(MathSymbol)
  case textStyle(MathTextStyle)
  case underSpreader(MathUnderSpreader)

  var command: String {
    switch self {
    case let .accent(accent): return accent.command
    case let .array(array): return array.command
    case let .genfrac(genfrac): return genfrac.command
    case let .operator_(operator_): return operator_.command
    case let .overSpreader(overSpreader): return overSpreader.command
    case let .symbol(symbol): return symbol.command
    case let .textStyle(textStyle): return textStyle.command
    case let .underSpreader(underSpreader): return underSpreader.command
    }
  }
}

extension MathDeclaration {
  static let predefinedCases: [MathDeclaration] = _predefinedCases()

  private static func _predefinedCases() -> [MathDeclaration] {
    var cases: [MathDeclaration] = []
    cases.append(contentsOf: MathAccent.predefinedCases.map { .accent($0) })
    cases.append(contentsOf: MathGenFrac.predefinedCases.map { .genfrac($0) })
    cases.append(contentsOf: MathArray.predefinedCases.map { .array($0) })
    cases.append(contentsOf: MathOperator.predefinedCases.map { .operator_($0) })
    cases.append(contentsOf: MathOverSpreader.predefinedCases.map { .overSpreader($0) })
    cases.append(contentsOf: MathUnderSpreader.predefinedCases.map { .underSpreader($0) })
    cases.append(contentsOf: MathSymbol.predefinedCases.map { .symbol($0) })
    cases.append(contentsOf: MathTextStyle.predefinedCases.map { .textStyle($0) })
    return cases
  }

  private static let _dictionary: [String: MathDeclaration] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathDeclaration? {
    _dictionary[command]
  }
}
