// Copyright 2024-2025 Lie Yan

/// Content wrapped in paired group delimitered or paired \begin/\end.
public enum WrappedContentSyntax: SyntaxProtocol {
  case arraySyntax(ArraySyntax)
  case streamSyntax(StreamSyntax)
}
