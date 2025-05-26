// Copyright 2024-2025 Lie Yan

public struct EnvironmentSyntax: SyntaxProtocol {
  public let beginClause: BeginClauseSyntax
  public let endClause: EndClauseSyntax
  public let wrapped: WrappedContentSyntax

  public init(
    beginClause: BeginClauseSyntax, endClause: EndClauseSyntax,
    wrapped: WrappedContentSyntax
  ) {
    precondition(beginClause.isPaired(with: endClause))
    self.beginClause = beginClause
    self.endClause = endClause
    self.wrapped = wrapped
  }
}
