// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation

protocol EditorProtocol {
    var layoutBounds: CGRect { get }
    func draw(_ rect: CGRect)
}
