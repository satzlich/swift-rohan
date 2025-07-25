public struct ParameterToken: TokenProtocol {
  public var parameterChar: Character { "#" }
  public let number: Int

  public init(_ number: Int) {
    precondition(ParameterToken.validate(number: number))
    self.number = number
  }

  public static func validate(number: Int) -> Bool {
    1...9 ~= number
  }
}

extension ParameterToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension ParameterToken {
  public func untokenize() -> String {
    "\(parameterChar)\(number)"
  }
}
