// Copyright 2024-2025 Lie Yan

import Foundation

struct Em: Equatable, Hashable {
    let floatValue: Double

    init(_ floatValue: Double) {
        precondition(floatValue.isFinite)
        self.floatValue = floatValue
    }

    static var zero: Em { Em(0.0) }

    // spacing
    static let thin = Em(1.0 / 6.0)
    static let medium = Em(2.0 / 9.0)
    static let thick = Em(5.0 / 18.0)
    static let quad = Em(1.0)
    static let wide = Em(2.0)
}
