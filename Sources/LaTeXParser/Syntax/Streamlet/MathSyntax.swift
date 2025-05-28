// Copyright 2024-2025 Lie Yan

public struct MathSyntax: SyntaxProtocol {
  public enum DelimiterType {
    case dollar
    case ddollar
    case bracket

    var openDelimiter: MathShiftToken {
      switch self {
      case .dollar: return .dollar
      case .ddollar: return .ddollar
      case .bracket: return .lbracket
      }
    }

    var closeDelimiter: MathShiftToken {
      switch self {
      case .dollar: return .dollar
      case .ddollar: return .ddollar
      case .bracket: return .rbracket
      }
    }
  }

  public let delimiter: DelimiterType
  public let content: StreamSyntax

  public init(delimiter: DelimiterType, content: StreamSyntax) {
    self.delimiter = delimiter
    self.content = content
  }
}

extension MathSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    var tokens: [any TokenProtocol] = []
    tokens.append(delimiter.openDelimiter)
    tokens.append(contentsOf: content.deparse())
    tokens.append(delimiter.closeDelimiter)
    return tokens
  }
}
