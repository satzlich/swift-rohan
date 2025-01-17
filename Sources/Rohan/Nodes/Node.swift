// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class Node {
    @usableFromInline
    internal weak var parent: Node?

    var isBlock: Bool { false }

    var length: Int { preconditionFailure() }
    var nsLength: Int { preconditionFailure() }
    final var summary: Summary {
        Summary(length: length, nsLength: nsLength)
    }

    /** Convert offset to `(path, offset)` */
    public final func locate(
        _ offset: Int,
        _ affinity: Affinity = .upstream
    ) -> (path: [RohanIndex], offset: Int) {
        var path = [RohanIndex]()
        let offset = _locate(offset, affinity, &path)
        return (path, offset)
    }

    /** Convert path to offset */
    public final func offset(_ path: [RohanIndex]) -> Int {
        var acc = 0
        _offset(path[...], &acc)
        return acc
    }

    /** Convert offset to `(context, return value)` */
    internal func _locate(_ offset: Int,
                          _ affinity: Affinity,
                          _ path: inout [RohanIndex]) -> Int
    {
        preconditionFailure("overriding required for \(type(of: self))")
    }

    /** Add offset to `acc` */
    internal func _offset(_ path: ArraySlice<RohanIndex>, _ acc: inout Int) {
        preconditionFailure("overriding required for \(type(of: self))")
    }

    public func copy() -> Node {
        preconditionFailure("overriding required for \(type(of: self))")
    }

    func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        preconditionFailure("overriding required for \(type(of: self))")
    }

    func _onContentChange(delta: Summary) {
        parent?._onContentChange(delta: delta)
    }

    struct Summary: Equatable, Hashable {
        let length: Int
        let nsLength: Int

        init(length: Int = 0, nsLength: Int = 0) {
            self.length = length
            self.nsLength = nsLength
        }

        static func + (lhs: Summary, rhs: Summary) -> Summary {
            Summary(length: lhs.length + rhs.length,
                    nsLength: lhs.nsLength + rhs.nsLength)
        }

        static func += (lhs: inout Summary, rhs: Summary) {
            lhs = lhs + rhs
        }

        static prefix func - (summary: Summary) -> Summary {
            Summary(length: -summary.length,
                    nsLength: -summary.nsLength)
        }
    }
}
