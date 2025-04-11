// Copyright 2024-2025 Lie Yan

import Foundation

public enum DefaultCommands {
  public static let allCases: [CommandRecord] = _defaultCommands()

  private static func _defaultCommands() -> [CommandRecord] {
    var commands = [CommandRecord]()

    // nodes
    commands.append(contentsOf: TextCommands.allCases)
    commands.append(contentsOf: MathCommands.allCases)

    // symbols
    do {
      let symbols = UniversalSymbols.allCases.map { CommandRecord($0, .plaintext) }
      commands.append(contentsOf: symbols)
    }
    do {
      let symbols = MathSymbols.allCases.map { CommandRecord($0, .mathListContent) }
      commands.append(contentsOf: symbols)
    }

    let commandSet = Set(commands.map { $0.name })
    assert(commandSet.count == commands.count, "Duplicate command found")

    return commands
  }
}
