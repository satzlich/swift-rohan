// Copyright 2024-2025 Lie Yan

public struct _GroupSyntax<T: SyntaxProtocol> {
  public enum DelimiterType {
    case braces
    case brackets

    var openDelimiter: GroupBeginningToken {
      switch self {
      case .braces: return .openBrace
      case .brackets: return .openBracket
      }
    }

    var closeDelimiter: GroupEndToken {
      switch self {
      case .braces: return .closeBrace
      case .brackets: return .closeBracket
      }
    }
  }

  public let delimiter: DelimiterType
  public let wrapped: T

  /// Create a group delimited by braces `{}`.
  public init(_ wrapped: T) {
    self.delimiter = .braces
    self.wrapped = wrapped
  }

  /// Create a group delimited by brackets `[]`.
  public init(_ delimiter: DelimiterType, _ wrapped: T) {
    self.delimiter = delimiter
    self.wrapped = wrapped
  }

  public func with(delimiter: DelimiterType) -> Self {
    Self(delimiter, wrapped)
  }
}

public typealias GroupSyntax = _GroupSyntax<StreamSyntax>

extension GroupSyntax {
  public init(_ streamlets: Array<StreamletSyntax>) {
    self.init(StreamSyntax(streamlets))
  }
}

extension GroupSyntax: SyntaxProtocol {
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    var tokens: Array<any TokenProtocol> = []
    tokens.append(delimiter.openDelimiter)
    tokens.append(contentsOf: wrapped.deparse(context))
    tokens.append(delimiter.closeDelimiter)
    return tokens
  }

  public func deparse(
    _ preference: DeparsePreference, _ context: DeparseContext
  ) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      return deparse(context)
    case .properGroup:
      let stream = self.wrapped.stream
      if stream.count == 1 {
        return stream.first!.deparse(.properGroup, context)
      }
      else {  // empty or multiple tokens
        return deparse(context)
      }
    }
  }
}
