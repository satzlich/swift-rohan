// Copyright 2024 Lie Yan

import Foundation

/**
 Identifier for node type.

 Used as subtype identifier for serialization.
 */
struct NodeType: Equatable, Hashable, Codable {
    let rawValue: String

    // MARK: - Predefined

    static let unknown = NodeType(rawValue: "unknown")
    static let root = NodeType(rawValue: "root")
    static let text = NodeType(rawValue: "text")
    static let paragraph = NodeType(rawValue: "paragraph")
}
