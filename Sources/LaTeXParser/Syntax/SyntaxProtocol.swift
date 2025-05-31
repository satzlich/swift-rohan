// Copyright 2024-2025 Lie Yan

public protocol SyntaxProtocol {
  func deparse(_ context: DeparseContext) -> Array<TokenProtocol>
}
