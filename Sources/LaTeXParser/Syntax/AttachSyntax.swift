// Copyright 2024-2025 Lie Yan

public struct AttachSyntax: SyntaxProtocol {
  public let nucleus: AtomSyntax
  public let subscript_: AtomSyntax?
  public let supscript: AtomSyntax?

  public init(nucleus: AtomSyntax, subscript_: AtomSyntax, supscript: AtomSyntax) {
    self.nucleus = nucleus
    self.subscript_ = subscript_
    self.supscript = supscript
  }

  public init(nucleus: AtomSyntax, subscript_: AtomSyntax) {
    self.nucleus = nucleus
    self.subscript_ = subscript_
    self.supscript = nil
  }

  public init(nucleus: AtomSyntax, supscript: AtomSyntax) {
    self.nucleus = nucleus
    self.subscript_ = nil
    self.supscript = supscript
  }
}
