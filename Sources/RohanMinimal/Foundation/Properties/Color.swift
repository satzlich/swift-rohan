// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public struct Color: Equatable, Hashable, Codable {
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

    public static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)
    public static let black = Color(red: 0, green: 0, blue: 0, alpha: 1)
    public static let white = Color(red: 1, green: 1, blue: 1, alpha: 1)
    public static let red = Color(red: 1, green: 0, blue: 0, alpha: 1)
    public static let green = Color(red: 0, green: 1, blue: 0, alpha: 1)
    public static let blue = Color(red: 0, green: 0, blue: 1, alpha: 1)
}
