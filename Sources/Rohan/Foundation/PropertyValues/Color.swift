// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public struct Color: Equatable, Hashable {
    // As NSColor and CGColor are frequently used, we store NSColor here
    private let _nsColor: NSColor
    public var nsColor: NSColor { _nsColor }

    var red: Double { _nsColor.redComponent }
    var green: Double { _nsColor.greenComponent }
    var blue: Double { _nsColor.blueComponent }
    var alpha: Double { _nsColor.alphaComponent }

    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self._nsColor = NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    public init(nsColor: NSColor) {
        self._nsColor = nsColor
    }

    public static let clear = Color(nsColor: NSColor.clear)
    public static let black = Color(nsColor: NSColor.black)
    public static let white = Color(nsColor: NSColor.white)
    public static let red = Color(nsColor: NSColor.red)
    public static let green = Color(nsColor: NSColor.green)
    public static let blue = Color(nsColor: NSColor.blue)
}

extension Color: Codable {
    enum CodingKeys: CodingKey { case red; case green; case blue; case alpha }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
        self._nsColor = NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(alpha, forKey: .alpha)
    }
}
