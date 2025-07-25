public struct StreamSyntax: SyntaxProtocol {
  public let stream: Array<StreamletSyntax>

  public init(_ stream: Array<StreamletSyntax>) {
    self.stream = stream
  }
}

extension StreamSyntax {
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    var tokens: Array<any TokenProtocol> = []

    var endsWithIdentifier = false
    var isAttach = false

    for streamlet in self.stream {
      let segment = streamlet.deparse(context)

      // add space between segments
      if let first = segment.first,
        (endsWithIdentifier || isAttach) && first.startsWithIdSpoiler
      {
        tokens.append(SpaceToken())
      }

      // save last
      if let last = segment.last {
        endsWithIdentifier = last.endsWithIdentifier
      }
      isAttach = streamlet.isAttach

      // append segment
      tokens.append(contentsOf: segment)
    }

    return tokens
  }

  public func getLatexContent(_ context: DeparseContext) -> String {
    self.deparse(context).map { $0.untokenize() }.joined()
  }
}
