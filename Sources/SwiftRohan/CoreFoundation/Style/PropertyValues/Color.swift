import AppKit
import Foundation

public struct Color: Equatable, Hashable, Sendable {
  // As NSColor and CGColor are frequently used, we store NSColor here
  public let nsColor: NSColor

  public var cgColor: CGColor { nsColor.cgColor }

  var red: Double { nsColor.redComponent }
  var green: Double { nsColor.greenComponent }
  var blue: Double { nsColor.blueComponent }
  var alpha: Double { nsColor.alphaComponent }

  public init(red: Double, green: Double, blue: Double, alpha: Double) {
    self.nsColor = NSColor(red: red, green: green, blue: blue, alpha: alpha)
  }

  public init(_ nsColor: NSColor) {
    self.nsColor = nsColor
  }

  func withAlpha(_ alpha: Double) -> Color {
    Color(nsColor.withAlphaComponent(alpha))
  }

  public static let clear = Color(NSColor.clear)
  public static let black = Color(NSColor.black)
  public static let white = Color(NSColor.white)
  public static let red = Color(NSColor.red)
  public static let green = Color(NSColor.green)
  public static let blue = Color(NSColor.blue)

  public static let brown = Color(NSColor.brown)
  public static let cyan = Color(NSColor.cyan)
  public static let gray = Color(NSColor.gray)
  public static let lightGray = Color(NSColor.lightGray)
  public static let darkGray = Color(NSColor.darkGray)
  public static let magenta = Color(NSColor.magenta)
  public static let yellow = Color(NSColor.yellow)
}

extension Color: Codable {
  private enum CodingKeys: CodingKey { case red, green, blue, alpha }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let red = try container.decode(Double.self, forKey: .red)
    let green = try container.decode(Double.self, forKey: .green)
    let blue = try container.decode(Double.self, forKey: .blue)
    let alpha = try container.decode(Double.self, forKey: .alpha)
    self.nsColor = NSColor(red: red, green: green, blue: blue, alpha: alpha)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(red, forKey: .red)
    try container.encode(green, forKey: .green)
    try container.encode(blue, forKey: .blue)
    try container.encode(alpha, forKey: .alpha)
  }
}
