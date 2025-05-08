// Copyright 2024-2025 Lie Yan

import SwiftSyntax

@freestanding(declaration, names: arbitrary)
public macro ErrorCode(code: Int, name: String, type: ErrorType) =
  #externalMacro(module: "RohanMacro", type: "ErrorCodeMacro")

public enum ErrorType: Int, Sendable {
  case UserError = 0
  case InternalError = 1
}

public struct ErrorCode: Equatable, Hashable, Sendable {
  public let code: Int
  public let name: String
  public let type: ErrorType

  public init(code: Int, name: String, type: ErrorType) {
    self.code = code
    self.name = name
    self.type = type
  }

  public static func == (lhs: ErrorCode, rhs: ErrorCode) -> Bool {
    lhs.code == rhs.code
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(code)
  }

  // MARK: - UserError

  #ErrorCode(code: 0x0000_0000, name: "GenericUserError", type: .UserError)

  /// Insert operation is rejected.
  #ErrorCode(code: 0x0000_0001, name: "InsertOperationRejected", type: .UserError)

  // MARK: - InternalError

  #ErrorCode(code: 0x0001_0000, name: "GenericInternalError", type: .InternalError)
  #ErrorCode(code: 0x0001_0001, name: "UnexpectedArgument", type: .InternalError)
  #ErrorCode(code: 0x0001_0002, name: "UnreachableCodePath", type: .InternalError)
  #ErrorCode(code: 0x0001_0003, name: "InvalidJSON", type: .InternalError)

  // location
  #ErrorCode(code: 0x0001_1001, name: "InvalidTextLocation", type: .InternalError)
  #ErrorCode(code: 0x0001_1002, name: "InvalidTextRange", type: .InternalError)
  #ErrorCode(code: 0x0001_1003, name: "InvalidMathComponent", type: .InternalError)

  // expected node
  #ErrorCode(code: 0x0001_2001, name: "ElementNodeExpected", type: .InternalError)
  #ErrorCode(code: 0x0001_2002, name: "ElementOrTextNodeExpected", type: .InternalError)

  // operation failure
  #ErrorCode(code: 0x0001_4001, name: "InsertStringFailure", type: .InternalError)
  #ErrorCode(code: 0x0001_4002, name: "InsertNodesFailure", type: .InternalError)
  #ErrorCode(code: 0x0001_4003, name: "DeleteRangeFailure", type: .InternalError)
  #ErrorCode(code: 0x0001_4004, name: "InsertMathComponentFailure", type: .InternalError)
}
