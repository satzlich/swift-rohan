// Copyright 2024-2025 Lie Yan

public struct DocumentSyntax: SyntaxProtocol {
  public let stream: StreamSyntax

  public init(_ stream: StreamSyntax) {
    self.stream = stream
  }

  public var preamble = TextSyntax(
    #"""
    \documentclass[10pt]{article}
    \usepackage[usenames]{color}
    \usepackage{amssymb}
    \usepackage{amsmath}
    \usepackage[utf8]{inputenc} 
    \usepackage{unicode-math}

    \begin{document}

    """#, mode: .rawMode)!

  public var postamble = TextSyntax(
    #"""

    \end{document}
    """#, mode: .rawMode)!
}

extension DocumentSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    [preamble] + stream.deparse() + [postamble]
  }
}
