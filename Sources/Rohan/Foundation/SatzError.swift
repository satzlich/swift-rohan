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
  #ErrorCode(code: 0x0000_0001, name: "InconsistentContent", type: .UserError)
  /// Content to insert is incompatible with the target location
  #ErrorCode(code: 0x0000_0002, name: "ContentToInsertIsIncompatible", type: .UserError)

  // MARK: - InternalError

  #ErrorCode(code: 0x0001_0000, name: "GenericInternalError", type: .InternalError)
  #ErrorCode(code: 0x0001_0001, name: "UnexpectedArgument", type: .InternalError)
  // location
  #ErrorCode(code: 0x0002_0001, name: "InvalidTextLocation", type: .InternalError)
  #ErrorCode(code: 0x0002_0002, name: "InvalidTextRange", type: .InternalError)
  // tree structure
  #ErrorCode(code: 0x0003_0001, name: "InvalidRootChild", type: .InternalError)
  // expected node
  #ErrorCode(code: 0x0004_0001, name: "ElementNodeExpected", type: .InternalError)
  #ErrorCode(code: 0x0004_0002, name: "TextNodeExpected", type: .InternalError)
  #ErrorCode(code: 0x0004_0003, name: "ElementOrTextNodeExpected", type: .InternalError)
  // json
  #ErrorCode(code: 0x0005_0001, name: "InvalidJSON", type: .InternalError)
  // operation failure
  #ErrorCode(code: 0x0006_0001, name: "InsertStringFailure", type: .InternalError)
  #ErrorCode(code: 0x0006_0002, name: "InsertParagraphBreakFailure", type: .InternalError)
  #ErrorCode(code: 0x0006_0003, name: "InsertNodesFailure", type: .InternalError)
  #ErrorCode(code: 0x0006_0004, name: "DeleteRangeFailure", type: .InternalError)
}

public struct SatzError: Error {
  public let code: ErrorCode
  public let message: String?

  public init(_ code: ErrorCode, message: String? = nil) {
    self.code = code
    self.message = message
  }
}

public typealias SatzResult<T> = Result<T, SatzError>
