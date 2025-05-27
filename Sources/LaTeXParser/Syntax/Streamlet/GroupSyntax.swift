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
  public init(brackets wrapped: T) {
    self.delimiter = .brackets
    self.wrapped = wrapped
  }
}

public typealias GroupSyntax = _GroupSyntax<StreamSyntax>

extension GroupSyntax {
  public init(_ streamlets: Array<StreamletSyntax>) {
    self.init(StreamSyntax(streamlets))
  }
}

extension GroupSyntax: SyntaxProtocol {
  public func deparse() -> Array<any TokenProtocol> {
    var tokens: Array<any TokenProtocol> = []
    tokens.append(delimiter.openDelimiter)
    tokens.append(contentsOf: wrapped.deparse())
    tokens.append(delimiter.closeDelimiter)
    return tokens
  }
}
