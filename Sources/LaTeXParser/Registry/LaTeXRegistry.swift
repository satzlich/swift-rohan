// Copyright 2024-2025 Lie Yan

public struct LaTeXRegistry {

  private var commands: Dictionary<NameToken, ControlSeqRecord> = [:]
  private var textSubs: SubsTable = [:]
  private var mathSubs: SubsTable = [:]

  /// Register a command. In case of conflict, the command will be overridden.
  /// - Parameter command: The command metadata to register.
  /// - Returns: The overridden command metadata if any, otherwise `nil`.
  public mutating func registerCommand(_ command: ControlSeqRecord) -> ControlSeqRecord? {
    commands.updateValue(command, forKey: command.command.name)
  }

  /// Register a substitution. In case of conflict, the substitution will be overridden.
  /// - Parameter substitution: The substitution metadata to register.
  /// - Returns: The overridden substitution metadata if any, otherwise `nil`.
  public mutating func registerSubstitution(
    _ substitution: SubstitutionRecord
  ) -> SubstitutionRecord? {
    switch substitution.mode {
    case .textMode:
      return textSubs.updateValue(substitution, forKey: substitution.character)
    case .mathMode:
      return mathSubs.updateValue(substitution, forKey: substitution.character)
    case .rawMode:
      assertionFailure("Raw mode substitutions are not supported.")
      return nil
    }
  }

  /// Returns the command metadata for the given command name.
  internal func commandRecord(for command: ControlWordToken) -> ControlSeqRecord? {
    commands[command.name]
  }

  internal typealias SubsTable = Dictionary<Character, SubstitutionRecord>

  internal func getSubsTable(for mode: LayoutMode) -> SubsTable {
    switch mode {
    case .textMode:
      return textSubs
    case .mathMode:
      return mathSubs
    case .rawMode:
      assertionFailure("Raw mode substitutions are not supported.")
      return [:]
    }
  }
}
