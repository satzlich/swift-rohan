// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

public enum CommandRecords {
  nonisolated(unsafe) public static let allCases: [CommandRecord] = _defaultCommands()

  private static func _defaultCommands() -> [CommandRecord] {
    var commands = [CommandRecord]()

    // nodes
    commands.append(contentsOf: TextCommands.allCases)
    commands.append(contentsOf: MathCommands.allCases)

    // symbols
    do {
      let symbols = NamedSymbol.allCommands.map { CommandRecord($0) }
      commands.append(contentsOf: symbols)
    }

    #if DEBUG
    do {
      let duplicates = findDuplicates(in: commands.map(\.name))
      assert(duplicates.isEmpty, "Duplicates found: \(duplicates)")
    }
    #endif

    return commands
  }
}
