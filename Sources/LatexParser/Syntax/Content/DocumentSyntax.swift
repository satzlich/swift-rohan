public struct DocumentSyntax: SyntaxProtocol {
  public let stream: StreamSyntax

  public init(_ stream: StreamSyntax) {
    self.stream = stream
  }

  public var beginDocument = TextSyntax(
    #"""
    \begin{document}

    """#, mode: .rawMode)!

  public var endDocument = TextSyntax(
    #"""

    \end{document}
    """#, mode: .rawMode)!
}

extension DocumentSyntax {
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    let preamble = TextToken(rawValue: context.registry.preamble, mode: .rawMode)
    return [preamble, NewlineToken(), beginDocument]
      + stream.deparse(context)
      + [endDocument]
  }

  public func getLatexContent(_ context: DeparseContext) -> String {
    deparse(context).map { $0.untokenize() }.joined()
  }
}
