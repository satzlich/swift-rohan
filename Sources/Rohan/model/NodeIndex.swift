// Copyright 2024 Lie Yan

import Foundation

struct NodeIndex: Equatable, Hashable {
    private let impl: IndexImpl

    private init(_ impl: IndexImpl) {
        self.impl = impl
    }

    static func regular(_ index: Int) -> NodeIndex {
        precondition(index >= 0)
        return NodeIndex(.regular(index))
    }

    static func grid(row: Int, column: Int) -> NodeIndex {
        precondition(row >= 0 && column >= 0)
        return NodeIndex(.grid(row: row, column: column))
    }

    enum IndexImpl: Equatable, Hashable, Codable {
        case regular(Int)
        case grid(row: Int, column: Int)
    }
}
