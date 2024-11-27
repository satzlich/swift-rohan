// Copyright 2024 Lie Yan

import Foundation

/**
 Identifier for node type.
 */
enum NodeType: Equatable, Hashable, Codable {
    case unknown
    case text
    // element
    case root
    case emphasis
    case heading
    case paragraph
    // math
    case equation
    case fraction
    case matrix
    case scripts
    // template
    case apply
    case variable
}
