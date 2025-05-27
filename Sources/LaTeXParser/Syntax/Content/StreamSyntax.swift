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
    // TODO: Handle streamlet syntax
    return tokens
  }
}
