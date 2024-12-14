// Copyright 2024 Lie Yan

import Foundation

extension Array {
    /// Returns the first and all the rest of the elements of the slice, or `none` if it is empty.
    @usableFromInline
    func splitFirst() -> (Element, ArraySlice<Element>)? {
        if isEmpty {
            return nil
        }
        return (self[0], self[1...])
    }

    /// Returns the last and all the rest of the elements of the slice, or `none` if it is empty.
    @usableFromInline
    func splitLast() -> (Element, ArraySlice<Element>)? {
        if isEmpty {
            return nil
        }
        return (self[count - 1], self[0 ..< count - 1])
    }
}
