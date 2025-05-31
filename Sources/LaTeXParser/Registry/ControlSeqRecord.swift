// Copyright 2024-2025 Lie Yan

public struct ControlSeqRecord {

  public let command: ControlWordToken
  public let genre: CommandGenre
  public let source: CommandSource

  public init(
    _ command: ControlWordToken,
    _ genre: CommandGenre,
    _ source: CommandSource
  ) {
    self.command = command
    self.genre = genre
    self.source = source
  }
}
