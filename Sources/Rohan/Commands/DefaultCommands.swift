// Copyright 2024-2025 Lie Yan

import Foundation

enum DefaultCommands {
  static let allCases: [CommandRecord] = _defaultCommands()

  private static func _defaultCommands() -> [CommandRecord] {
    var commands = [CommandRecord]()

    // nodes
    commands.append(contentsOf: TextCommands.allCases)
    commands.append(contentsOf: MathCommands.allCases)

    // symbols
    do {
      let symbols = UniversalSymbols.allCases.map { $0.toCommandRecord(.plaintext) }
      commands.append(contentsOf: symbols)
    }
    do {
      let symbols = MathSymbols.allCases.map { $0.toCommandRecord(.mathListContent) }
      commands.append(contentsOf: symbols)
    }

    let commandSet = Set(commands.map { $0.command })
    assert(commandSet.count == commands.count, "Duplicate command found")

    return commands
  }
}
