// Copyright 2024-2025 Lie Yan

public struct AttachSyntax: SyntaxProtocol {
  public let nucleus: ComponentSyntax
  public let subscript_: ComponentSyntax?
  public let supscript: ComponentSyntax?

  public init(nucleus: ComponentSyntax, subscript_: ComponentSyntax, supscript: ComponentSyntax) {
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
