public struct ControlSeqRecord {

  public let command: ControlWordToken
  public let tag: CommandTag
  public let source: CommandSource

  public init(_ command: ControlWordToken, _ tag: CommandTag, _ source: CommandSource) {
    self.command = command
    self.tag = tag
    self.source = source
  }
}
