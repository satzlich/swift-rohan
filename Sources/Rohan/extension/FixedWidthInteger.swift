// Copyright 2024 Lie Yan

import Foundation

extension FixedWidthInteger {
    static var leadBitMask: Self {
        1 << (bitWidth - 1)
    }
}
