// Copyright 2024-2025 Lie Yan

public func deparse(_ syntax: SyntaxProtocol) -> String {
  syntax.deparse().map { $0.untokenize() }.joined()
}
