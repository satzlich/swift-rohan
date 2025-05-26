// Copyright 2024-2025 Lie Yan

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
