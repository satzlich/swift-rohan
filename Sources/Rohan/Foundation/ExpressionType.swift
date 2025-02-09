// Copyright 2024-2025 Lie Yan

import Foundation

public enum ExpressionType: Equatable, Hashable, CaseIterable, Codable {
    // Expression
    case apply
    case variable
    case namelessVariable

    // Construction Bricks
    case linebreak
    case text

    // Elements
    case content
    case emphasis
    case heading
    case paragraph
    case root
    case textMode

    // Math
    case equation
    case fraction
    case matrix
    case scripts
}

public typealias NodeType = ExpressionType

extension NodeType {
    @inline(__always)
    static let blockElements: Set<NodeType> = [.heading, .paragraph]

    @inline(__always)
    static let opaqueNodes: Set<NodeType> =
        Set(NodeType.allCases).subtracting(transparentNodes)

    @inline(__always)
    private static let transparentNodes: Set<NodeType> = [
        .paragraph,
        .text,
    ]
}
