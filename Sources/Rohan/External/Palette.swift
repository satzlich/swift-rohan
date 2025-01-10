// Copyright 2024-2025 Lie Yan

import AppKit
import CoreGraphics
import Foundation

public enum Palette {
    public struct RGBAColor: Equatable, Hashable, Codable {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        public init(red: Double, green: Double, blue: Double, alpha: Double) {
            self.red = red.clamped(0, 1)
            self.green = green.clamped(0, 1)
            self.blue = blue.clamped(0, 1)
            self.alpha = alpha.clamped(0, 1)
        }

        public var nsColor: NSColor {
            NSColor(red: red, green: green, blue: blue, alpha: alpha)
        }

        public static let clear = RGBAColor(red: 0, green: 0, blue: 0, alpha: 0)
        public static let black = RGBAColor(red: 0, green: 0, blue: 0, alpha: 1)
        public static let white = RGBAColor(red: 1, green: 1, blue: 1, alpha: 1)
        public static let red = RGBAColor(red: 1, green: 0, blue: 0, alpha: 1)
        public static let green = RGBAColor(red: 0, green: 1, blue: 0, alpha: 1)
        public static let blue = RGBAColor(red: 0, green: 0, blue: 1, alpha: 1)
    }

    public typealias Color = RGBAColor
}
