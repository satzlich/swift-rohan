// Copyright 2024-2025 Lie Yan

public struct DocumentSyntax: SyntaxProtocol {
  public let stream: StreamSyntax
}

extension DocumentSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    stream.deparse()
  }
}
