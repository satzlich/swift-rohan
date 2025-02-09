// Copyright 2024-2025 Lie Yan

import SwiftSyntax

@freestanding(declaration, names: arbitrary)
public macro ErrorCode(code: Int, name: String, type: ErrorType) = #externalMacro(
    module: "RohanMacro",
    type: "ErrorCodeMacro"
)

public enum ErrorType: Int {
    case UserError = 0
    case InternalError = 1
}

public struct ErrorCode: Equatable, Hashable {
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

    // MARK: - InternalError

    #ErrorCode(code: 0x0001_0000, name: "GenericInternalError", type: .InternalError)
    #ErrorCode(code: 0x0001_0001, name: "InvalidTextLocation", type: .InternalError)
    #ErrorCode(code: 0x0001_0002, name: "InvalidTextRange", type: .InternalError)
    #ErrorCode(code: 0x0001_0003, name: "InsaneRootChild", type: .InternalError)
}

public struct SatzError: Error {
    public let code: ErrorCode
    public let message: String?

    public init(_ code: ErrorCode, message: String? = nil) {
        self.code = code
        self.message = message
    }
}
