// Copyright 2024-2025 Lie Yan

import Foundation

enum CommandDeclaration: CommandDeclarationProtocol {
  case mathAccent(MathAccent)
  case mathArray(MathArray)
  case mathAttributes(MathAttributes)
  case mathExpression(MathExpression)
  case mathGenFrac(MathGenFrac)
  case mathOperator(MathOperator)
  case mathSpreader(MathSpreader)
  case mathTemplate(MathTemplate)
  case mathStyles(MathStyles)
  case namedSymbol(NamedSymbol)

  var command: String {
    switch self {
    case let .mathAccent(accent): return accent.command
    case let .mathArray(array): return array.command
    case let .mathExpression(expression): return expression.command
    case let .mathGenFrac(genfrac): return genfrac.command
    case let .mathAttributes(attributes): return attributes.command
    case let .mathOperator(operator_): return operator_.command
    case let .mathSpreader(spreader): return spreader.command
    case let .mathStyles(styles): return styles.command
    case let .mathTemplate(template): return template.command
    case let .namedSymbol(symbol): return symbol.command
    }
  }
}

extension CommandDeclaration {
  static let allCommands: [CommandDeclaration] = _predefinedCases()

  private static func _predefinedCases() -> [CommandDeclaration] {
    var cases: [CommandDeclaration] = []
    cases.append(contentsOf: MathAccent.allCommands.map { .mathAccent($0) })
    cases.append(contentsOf: MathArray.allCommands.map { .mathArray($0) })
    cases.append(contentsOf: MathAttributes.allCommands.map { .mathAttributes($0) })
    cases.append(contentsOf: MathExpression.allCommands.map { .mathExpression($0) })
    cases.append(contentsOf: MathGenFrac.allCommands.map { .mathGenFrac($0) })
    cases.append(contentsOf: MathOperator.allCommands.map { .mathOperator($0) })
    cases.append(contentsOf: MathSpreader.allCommands.map { .mathSpreader($0) })
    cases.append(contentsOf: MathStyles.allCommands.map { .mathStyles($0) })
    cases.append(contentsOf: MathTemplate.allCommands.map { .mathTemplate($0) })
    cases.append(contentsOf: NamedSymbol.allCommands.map { .namedSymbol($0) })
    return cases
  }

  private static let _dictionary: [String: CommandDeclaration] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> CommandDeclaration? {
    _dictionary[command]
  }
}
