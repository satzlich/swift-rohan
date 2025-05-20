// Copyright 2024-2025 Lie Yan

import Foundation

enum CommandDeclaration: CommandDeclarationProtocol {
  case mathAccent(MathAccent)
  case mathArray(MathArray)
  case mathExpression(MathExpression)
  case mathGenFrac(MathGenFrac)
  case mathKind(MathKind)
  case mathOperator(MathOperator)
  case mathSpreader(MathSpreader)
  case mathSymbol(MathSymbol)
  case mathTextStyle(MathTextStyle)

  var command: String {
    switch self {
    case let .mathAccent(accent): return accent.command
    case let .mathArray(array): return array.command
    case let .mathExpression(expression): return expression.command
    case let .mathGenFrac(genfrac): return genfrac.command
    case let .mathKind(kind): return kind.command
    case let .mathOperator(operator_): return operator_.command
    case let .mathSpreader(spreader): return spreader.command
    case let .mathSymbol(symbol): return symbol.command
    case let .mathTextStyle(textStyle): return textStyle.command
    }
  }
}

extension CommandDeclaration {
  static let predefinedCases: [CommandDeclaration] = _predefinedCases()

  private static func _predefinedCases() -> [CommandDeclaration] {
    var cases: [CommandDeclaration] = []
    cases.append(contentsOf: MathAccent.predefinedCases.map { .mathAccent($0) })
    cases.append(contentsOf: MathArray.predefinedCases.map { .mathArray($0) })
    cases.append(contentsOf: MathExpression.predefinedCases.map { .mathExpression($0) })
    cases.append(contentsOf: MathGenFrac.predefinedCases.map { .mathGenFrac($0) })
    cases.append(contentsOf: MathKind.predefinedCases.map { .mathKind($0) })
    cases.append(contentsOf: MathOperator.predefinedCases.map { .mathOperator($0) })
    cases.append(contentsOf: MathSpreader.predefinedCases.map { .mathSpreader($0) })
    cases.append(contentsOf: MathSymbol.predefinedCases.map { .mathSymbol($0) })
    cases.append(contentsOf: MathTextStyle.predefinedCases.map { .mathTextStyle($0) })
    return cases
  }

  private static let _dictionary: [String: CommandDeclaration] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> CommandDeclaration? {
    _dictionary[command]
  }
}
