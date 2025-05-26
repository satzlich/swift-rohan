// Copyright 2024-2025 Lie Yan

public struct MathSyntax: SyntaxProtocol {
  public let open: MathShiftToken
  public let close: MathShiftToken
  public let content: WrappedContentSyntax
}
