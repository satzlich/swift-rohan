// Copyright 2024-2025 Lie Yan

public struct AttachSyntax: SyntaxProtocol {
  public let nucleus: AtomSyntax
  public let subscript_: AtomSyntax?
  public let supscript: AtomSyntax?

  public init(nucleus: AtomSyntax, subscript_: AtomSyntax?, supscript: AtomSyntax?) {
    precondition(subscript_ != nil || supscript != nil)
    self.nucleus = nucleus
    self.subscript_ = subscript_
    self.supscript = supscript
  }
}
