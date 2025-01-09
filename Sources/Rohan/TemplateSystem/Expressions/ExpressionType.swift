// Copyright 2024-2025 Lie Yan

import Foundation

public enum ExpressionType: Equatable, Hashable, CaseIterable, Codable {
    // Expression
    case apply
    case variable
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

    // Extra for nodes

    case root
    case unknown
}

extension Expression {
    var type: ExpressionType {
        switch self {
        case .apply:
            return .apply
        case .variable:
            return .variable
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
