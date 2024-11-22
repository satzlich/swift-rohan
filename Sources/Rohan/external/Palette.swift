// Copyright 2024 Lie Yan

import CoreGraphics
import Foundation

enum Palette {
    struct RGBAColor: Equatable, Hashable, Codable {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        init(red: Double, green: Double, blue: Double, alpha: Double) {
            self.red = red.clamped(0, 1)
            self.green = green.clamped(0, 1)
            self.blue = blue.clamped(0, 1)
            self.alpha = alpha.clamped(0, 1)
        }

        var cgColor: CGColor {
            CGColor(
                red: red,
                green: green,
                blue: blue,
                alpha: alpha
            )
        }
    }

    typealias Color = RGBAColor
}
