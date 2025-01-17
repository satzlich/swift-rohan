// Copyright 2024-2025 Lie Yan

import Foundation

enum HomoTree<T>: CustomStringConvertible {
    case Leaf(T)
    case Node(T, [HomoTree<T>])

    var value: T {
        switch self {
        case let .Leaf(value):
            return value
        case let .Node(value, _):
            return value
        }
    }

    var description: String {
        switch self {
        case let .Leaf(value):
            return "`\(value)`"
        case let .Node(value, children):
            return "(\(value), \(children))"
        }
    }
}
