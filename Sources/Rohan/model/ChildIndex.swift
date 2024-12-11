// Copyright 2024 Lie Yan

import Foundation

struct ChildIndex: Equatable, Hashable {
    private let impl: IndexImpl

    private init(_ impl: IndexImpl) {
        self.impl = impl
    }

    static func regular(_ index: Int) -> ChildIndex {
        precondition(index >= 0)
        return ChildIndex(.regular(index))
    }

    static func grid(row: Int, column: Int) -> ChildIndex {
        precondition(row >= 0 && column >= 0)
        return ChildIndex(.grid(row: row, column: column))
    }

    enum IndexImpl: Equatable, Hashable, Codable {
        case regular(Int)
        case grid(row: Int, column: Int)
    }
}
