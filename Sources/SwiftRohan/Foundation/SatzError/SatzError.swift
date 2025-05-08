// Copyright 2024-2025 Lie Yan

public struct SatzError: Error {
  public let code: ErrorCode
  public let message: String?

  public init(_ code: ErrorCode, message: String? = nil) {
    self.code = code
    self.message = message
  }
}

public typealias SatzResult<T> = Result<T, SatzError>
