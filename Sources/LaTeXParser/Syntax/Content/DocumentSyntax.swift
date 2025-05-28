// Copyright 2024-2025 Lie Yan

public struct DocumentSyntax: SyntaxProtocol {
  public let stream: StreamSyntax

  public init(_ stream: StreamSyntax) {
    self.stream = stream
  }
}

extension DocumentSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    stream.deparse()
  }
}
