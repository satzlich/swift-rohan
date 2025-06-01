// Copyright 2024-2025 Lie Yan

public struct LatexRegistry {
  /// Substitution table.
  internal typealias SubsTable = Dictionary<Character, SubstitutionRecord>

  private var commands: Dictionary<NameToken, ControlSeqRecord> = [:]
  private var textSubs: SubsTable = [:]
  private var mathSubs: SubsTable = [:]

  public static var defaultPreamble: String =
    #"""
    \documentclass[10pt]{article}
    \usepackage[usenames]{color}
    \usepackage{amssymb}
    \usepackage{amsmath}
    \usepackage[utf8]{inputenc} 
    \usepackage{unicode-math}
    """#

  /// Custom preamble for the LaTeX document.
  public var preamble: String = LatexRegistry.defaultPreamble

  public init() {}

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
  internal func commandGenre(of command: ControlWordToken) -> CommandGenre? {
    commands[command.name]?.genre
  }

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

  internal static var defaultValue: LatexRegistry { LatexRegistry() }
}
