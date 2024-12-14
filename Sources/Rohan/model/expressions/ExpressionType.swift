// Copyright 2024 Lie Yan

import Foundation

enum ExpressionType: Equatable, Hashable, CaseIterable {
    // Expression
    case apply
    case variable

    // Nameless
    case namelessApply
    case namelessVariable

    // Basics
    case text
    case content
    case emphasis
    case heading
    case paragraph

    // Math
    case equation
    case fraction
    case matrix
    case scripts
}

extension Expression {
    var type: ExpressionType {
        switch self {
        case .apply:
            return .apply
        case .variable:
            return .variable
        case .namelessApply:
            return .namelessApply
        case .namelessVariable:
            return .namelessVariable
        case .text:
            return .text
        case .content:
            return .content
        case .emphasis:
            return .emphasis
        case .heading:
            return .heading
        case .paragraph:
            return .paragraph
        case .equation:
            return .equation
        case .fraction:
            return .fraction
        case .matrix:
            return .matrix
        case .scripts:
            return .scripts
        }
    }
}
