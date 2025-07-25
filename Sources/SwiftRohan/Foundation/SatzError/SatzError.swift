public struct SatzError: Error {
  public let code: ErrorCode
  public let message: String?

  public init(_ code: ErrorCode, message: String? = nil) {
    self.code = code
    self.message = message
  }
}

extension SatzError: Equatable {
  public static func == (lhs: SatzError, rhs: SatzError) -> Bool {
    lhs.code == rhs.code && lhs.message == rhs.message
  }
}

public typealias SatzResult<T> = Result<T, SatzError>
