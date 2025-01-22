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

    case unknown
    case root
    case textMode
}

public typealias NodeType = ExpressionType

extension NodeType {
    /** The tags of block elements */
    static let blockElements: Set<NodeType> =
        [
            .heading,
            .paragraph,
        ]
}
