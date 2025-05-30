// Copyright 2024-2025 Lie Yan

public struct ControlSeqRecord {
  public enum CommandGenre {
    case mathOperator
    case namedSymbol
    case other
  }

  public let command: ControlWordToken
  public let genre: CommandGenre
  public let source: CommandSouce

  public init(
    _ command: ControlWordToken,
    _ genre: CommandGenre,
    _ source: CommandSouce
  ) {
    self.command = command
    self.genre = genre
    self.source = source
  }
}
