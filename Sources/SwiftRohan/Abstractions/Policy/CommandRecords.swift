// Copyright 2024-2025 Lie Yan

import Foundation

public enum CommandRecords {
  public static let allCases: [CommandRecord] = _defaultCommands()

  private static func _defaultCommands() -> [CommandRecord] {
    var commands = [CommandRecord]()

    // nodes
    commands.append(contentsOf: TextCommands.allCases)
    commands.append(contentsOf: MathCommands.allCases)

    // symbols
    do {
      let symbols = TextMathSymbols.allCases.map { CommandRecord($0, .plaintext) }
      commands.append(contentsOf: symbols)
    }
    do {
      let symbols = MathSymbols.allCases.map { CommandRecord($0, .mathText) }
      commands.append(contentsOf: symbols)
    }

    #if DEBUG
    let commandList = commands.map { $0.name }
    let duplicates = findDuplicates(in: commandList)
    assert(duplicates.isEmpty, "Duplicate command names found: \(duplicates)")
    #endif

    return commands
  }

  private static func findDuplicates(in strings: [String]) -> [String] {
    var seen = Set<String>()
    var duplicates = Set<String>()

    for string in strings {
      if seen.contains(string) {
        duplicates.insert(string)
      }
      else {
        seen.insert(string)
      }
    }

    return Array(duplicates)
  }
}
