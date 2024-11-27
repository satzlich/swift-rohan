// Copyright 2024 Lie Yan

import Foundation

/**
 Generalized element
 */
protocol GenElement {
    var children: [Node] { get }
    var isInline: Bool { get }
}
