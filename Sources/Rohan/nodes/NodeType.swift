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
    static let text = NodeType(rawValue: "text")
    //
    static let root = NodeType(rawValue: "root")
    static let paragraph = NodeType(rawValue: "paragraph")
    static let heading = NodeType(rawValue: "heading")
    static let emphasis = NodeType(rawValue: "emphasis")
    //
    static let equation = NodeType(rawValue: "equation")
    static let scripts = NodeType(rawValue: "scripts")
    static let fraction = NodeType(rawValue: "fraction")
    static let matrix = NodeType(rawValue: "matrix")
    ///
    static let apply = NodeType(rawValue: "apply")
    static let variable = NodeType(rawValue: "variable")
}
