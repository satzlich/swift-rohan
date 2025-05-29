// Copyright 2024-2025 Lie Yan

public struct StreamSyntax: SyntaxProtocol {
  public let stream: Array<StreamletSyntax>

  public init(_ stream: Array<StreamletSyntax>) {
    self.stream = stream
  }
}

extension StreamSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    var tokens: Array<any TokenProtocol> = []

    var endsWithIdentifier = false

    for streamlet in self.stream {
      let segment = streamlet.deparse()
      if let first = segment.first,
        endsWithIdentifier && first.startsWithIdentifierUnsafe
      {
        tokens.append(SpaceToken())
      }
      if let last = segment.last {
        endsWithIdentifier = last.endsWithIdentifier
      }
      tokens.append(contentsOf: segment)
    }

    return tokens
  }

  public func exportLaTeX() -> String {
    self.deparse().map { $0.deparse() }.joined()
  }
}
