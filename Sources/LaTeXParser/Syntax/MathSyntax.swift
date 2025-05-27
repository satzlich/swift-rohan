// Copyright 2024-2025 Lie Yan

public struct MathSyntax: SyntaxProtocol {
  public let open: MathShiftToken
  public let close: MathShiftToken
  public let content: WrappedContentSyntax

  public init(open: MathShiftToken, close: MathShiftToken, content: WrappedContentSyntax)
  {
    self.open = open
    self.close = close
    self.content = content
  }
}
