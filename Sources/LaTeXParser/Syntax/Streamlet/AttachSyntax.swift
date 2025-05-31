// Copyright 2024-2025 Lie Yan

public struct AttachSyntax: SyntaxProtocol {
  public let nucleus: ComponentSyntax
  public let subscript_: ComponentSyntax?
  public let supscript: ComponentSyntax?

  public init(
    nucleus: ComponentSyntax,
    subscript_: ComponentSyntax?,
    supscript: ComponentSyntax?
  ) {
    precondition(supscript != nil || subscript_ != nil)
    self.nucleus = nucleus
    self.subscript_ = subscript_
    self.supscript = supscript
  }
}

extension AttachSyntax {
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    var tokens: [any TokenProtocol] = []

    tokens.append(contentsOf: nucleus.deparse(.minGroup, context))
    if let subscript_ = subscript_ {
      tokens.append(SubscriptToken())
      tokens.append(contentsOf: subscript_.deparse(.wrapNonSymbol, context))
    }
    if let supscript = supscript {
      tokens.append(SuperscriptToken())
      tokens.append(contentsOf: supscript.deparse(.wrapNonSymbol, context))
    }

    return tokens
  }
}
