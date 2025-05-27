// Copyright 2024-2025 Lie Yan

public typealias AlignmentTabSyntax = AlignmentTabToken

extension AlignmentTabSyntax: SyntaxProtocol {
  public func deparse() -> Array<any TokenProtocol> {
    [self]
  }
}
