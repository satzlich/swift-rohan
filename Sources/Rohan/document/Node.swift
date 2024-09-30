// Copyright 2024 Lie Yan

protocol Node: AnyObject {
    var parent: Node? { get }
    var children: [Node] { get }
}
