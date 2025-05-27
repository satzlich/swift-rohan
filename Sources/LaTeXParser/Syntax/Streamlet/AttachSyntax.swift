// Copyright 2024-2025 Lie Yan

public struct AttachSyntax: SyntaxProtocol {
  public let nucleus: ComponentSyntax
  public let subscript_: ComponentSyntax?
  public let supscript: ComponentSyntax?

  public init(
    nucleus: ComponentSyntax,
    subscript_: ComponentSyntax,
    supscript: ComponentSyntax
  ) {
    self.nucleus = nucleus
    self.subscript_ = subscript_
    self.supscript = supscript
  }

  public init(nucleus: ComponentSyntax, subscript_: ComponentSyntax) {
    self.nucleus = nucleus
    self.subscript_ = subscript_
    self.supscript = nil
  }

  public init(nucleus: ComponentSyntax, supscript: ComponentSyntax) {
    self.nucleus = nucleus
    self.subscript_ = nil
    self.supscript = supscript
  }
}

extension AttachSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    var tokens: [any TokenProtocol] = []

    tokens.append(contentsOf: nucleus.deparse())
    if let subscript_ = subscript_ {
      tokens.append(SubscriptToken())
      tokens.append(contentsOf: subscript_.deparse())
    }
    if let supscript = supscript {
      tokens.append(SuperscriptToken())
      tokens.append(contentsOf: supscript.deparse())
    }

    return tokens
  }
}
