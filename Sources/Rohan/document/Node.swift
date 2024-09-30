// Copyright 2024 Lie Yan

// MARK: - Node

protocol Node: AnyObject {
    var parent: Node? { get }
    var children: [Node] { get }
}
