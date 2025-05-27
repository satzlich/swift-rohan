// Copyright 2024-2025 Lie Yan

public struct _EnvironmentSyntax<T: SyntaxProtocol>: SyntaxProtocol {
  public let name: NameToken
  public let wrapped: T

  public init(name: NameToken, wrapped: T) {
    self.name = name
    self.wrapped = wrapped
  }

  public var beginClause: CommandSeqSyntax {
    CommandSeqSyntax.unaryCall(command: .begin, argument: TextSyntax(name.string))
  }

  public var endClause: CommandSeqSyntax {
    CommandSeqSyntax.unaryCall(command: .end, argument: TextSyntax(name.string))
  }

  public func deparse() -> Array<any TokenProtocol> {
    var tokens: [any TokenProtocol] = []

    tokens.append(contentsOf: beginClause.deparse())
    tokens.append(contentsOf: wrapped.deparse())
    tokens.append(contentsOf: endClause.deparse())

    return tokens
  }
}

public typealias EnvironmentSyntax = _EnvironmentSyntax<StreamSyntax>
public typealias ArrayEnvSyntax = _EnvironmentSyntax<ArraySyntax>
