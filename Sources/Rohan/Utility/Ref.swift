// Copyright 2024 Lie Yan

import Foundation

final class Ref<T> {
    let val: T

    init(_ val: T) {
        self.val = val
    }
}
