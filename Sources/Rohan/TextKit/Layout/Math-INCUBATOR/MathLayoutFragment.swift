// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

protocol MathLayoutFragment: LayoutFragment {
    // MARK: - Frame

    func setFrameOrigin(_ origin: CGPoint)

    // MARK: Metrics

    var width: Double { get }
    var ascent: Double { get }
    var descent: Double { get }
    var height: Double { get }
    var italicsCorrection: Double { get }
    var accentAttachment: Double { get }

    // MARK: - Categories

    var clazz: MathClass { get }
    var limits: Limits { get }

    // MARK: - Flags

    var isSpaced: Bool { get }
    var isTextLike: Bool { get }

    // MARK: Length

    var nsLength: Int { get }
}
