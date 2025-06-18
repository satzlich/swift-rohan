// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

enum CommandDeclaration: CommandDeclarationProtocol {
  case mathAccent(MathAccent)
  case mathArray(MathArray)
  case mathAttributes(MathAttributes)
  case mathExpression(MathExpression)
  case mathGenFrac(MathGenFrac)
  case mathOperator(MathOperator)
  case mathSpreader(MathSpreader)
  case mathStyles(MathStyles)
  case mathTemplate(MathTemplate)
  case namedSymbol(NamedSymbol)
  case textStyles(TextStyles)

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
    case let .textStyles(styles): return styles.command
    }
  }

  var tag: CommandTag {
    switch self {
    case let .mathAccent(accent): return accent.tag
    case let .mathArray(array): return array.tag
    case let .mathExpression(expression): return expression.tag
    case let .mathGenFrac(genfrac): return genfrac.tag
    case let .mathAttributes(attributes): return attributes.tag
    case let .mathOperator(operator_): return operator_.tag
    case let .mathSpreader(spreader): return spreader.tag
    case let .mathStyles(styles): return styles.tag
    case let .mathTemplate(template): return template.tag
    case let .namedSymbol(symbol): return symbol.tag
    case let .textStyles(styles): return styles.tag
    }
  }

  var source: CommandSource {
    switch self {
    case let .mathAccent(accent): return accent.source
    case let .mathArray(array): return array.source
    case let .mathExpression(expression): return expression.source
    case let .mathGenFrac(genfrac): return genfrac.source
    case let .mathAttributes(attributes): return attributes.source
    case let .mathOperator(operator_): return operator_.source
    case let .mathSpreader(spreader): return spreader.source
    case let .mathStyles(styles): return styles.source
    case let .mathTemplate(template): return template.source
    case let .namedSymbol(symbol): return symbol.source
    case let .textStyles(styles): return styles.source
    }
  }
}

extension CommandDeclaration {
  nonisolated(unsafe) static let allCommands: Array<CommandDeclaration> =
    _predefinedCases()

  private static func _predefinedCases() -> Array<CommandDeclaration> {
    var cases: Array<CommandDeclaration> = []
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
    cases.append(contentsOf: TextStyles.allCommands.map { .textStyles($0) })
    return cases
  }

  nonisolated(unsafe) private static let _dictionary:
    Dictionary<String, CommandDeclaration> =
      Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> CommandDeclaration? {
    _dictionary[command]
  }
}
