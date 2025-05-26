// Copyright 2024-2025 Lie Yan

public struct EnvironmentSyntax: SyntaxProtocol {
  public let beginClause: BeginClauseSyntax
  public let endClause: EndClauseSyntax
  public let wrapped: ContentSyntax

  public init(
    beginClause: BeginClauseSyntax, endClause: EndClauseSyntax, wrapped: ContentSyntax
  ) {
    precondition(beginClause.name == endClause.name)
    self.beginClause = beginClause
    self.endClause = endClause
    self.wrapped = wrapped
  }
}
