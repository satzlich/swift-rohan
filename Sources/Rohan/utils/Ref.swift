// Copyright 2024 Lie Yan

import Foundation

final class Ref<T> {
    var value: T
    init(_ value: T) {
        self.value = value
    }
}
