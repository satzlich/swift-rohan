// Copyright 2024-2025 Lie Yan

public typealias TextSyntax = TextToken

extension TextSyntax: SyntaxProtocol {
  public func deparse() -> Array<any TokenProtocol> {
    return [self]
  }

  public func deparse(_ preference: DeparsePreference) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      return deparse()
    case .properGroup:
      return text.count == 1
        ? deparse()
        : wrapInGroup(deparse())
    }
  }
}
