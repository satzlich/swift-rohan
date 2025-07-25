public struct _EnvironmentSyntax<T: SyntaxProtocol>: SyntaxProtocol {
  public let name: NameToken
  public let wrapped: T

  public init(name: NameToken, wrapped: T) {
    self.name = name
    self.wrapped = wrapped
  }

  public var beginClause: ControlWordSyntax {
    ControlWordSyntax.unaryCall(
      command: .begin, argument: TextSyntax(name.string, mode: .rawMode)!)
  }

  public var endClause: ControlWordSyntax {
    ControlWordSyntax.unaryCall(
      command: .end, argument: TextSyntax(name.string, mode: .rawMode)!)
  }

  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    var tokens: Array<any TokenProtocol> = []

    tokens.append(contentsOf: beginClause.deparse(context))
    tokens.append(NewlineToken())
    tokens.append(contentsOf: wrapped.deparse(context))
    tokens.append(NewlineToken())
    tokens.append(contentsOf: endClause.deparse(context))

    return tokens
  }
}

public typealias EnvironmentSyntax = _EnvironmentSyntax<StreamSyntax>
public typealias ArrayEnvSyntax = _EnvironmentSyntax<ArraySyntax>
