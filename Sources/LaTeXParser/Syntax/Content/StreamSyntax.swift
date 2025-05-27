// Copyright 2024-2025 Lie Yan

public struct StreamSyntax: SyntaxProtocol {
  public let stream: Array<StreamletSyntax>

  public init(stream: Array<StreamletSyntax>) {
    self.stream = stream
  }
}
