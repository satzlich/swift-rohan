// Copyright 2024 Lie Yan

import Foundation

protocol ElementProtocol {
    var children: [Node] { get }
    var isInline: Bool { get }
}
