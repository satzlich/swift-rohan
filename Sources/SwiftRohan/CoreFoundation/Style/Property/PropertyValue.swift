import AppKit
import Foundation

internal enum PropertyValue: Equatable, Hashable, Codable, Sendable {
  case none

  // basic types
  case bool(Bool)
  case integer(Int)
  case float(Double)
  case string(String)

  // general
  case absLength(AbsLength)
  case color(Color)

  // font
  case fontSize(FontSize)
  case fontStretch(FontStretch)
  case fontStyle(FontStyle)
  case fontWeight(FontWeight)

  // math
  case mathStyle(MathStyle)
  case mathVariant(MathVariant)

  // paragraph
  case textAlignment(NSTextAlignment)

  public var type: PropertyValueType {
    switch self {
    case .none: return .none
    // ---
    case .bool: return .bool
    case .integer: return .integer
    case .float: return .float
    case .string: return .string
    // ---
    case .absLength: return .absLength
    case .color: return .color
    // ---
    case .fontSize: return .fontSize
    case .fontStretch: return .fontStretch
    case .fontStyle: return .fontStyle
    case .fontWeight: return .fontWeight
    // ---
    case .mathStyle: return .mathStyle
    case .mathVariant: return .mathVariant
    //
    case .textAlignment: return .textAlignment
    }
  }
}

extension PropertyValue {
  @inlinable @inline(__always)
  public func bool() -> Bool? {
    switch self {
    case let .bool(bool): return bool
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func integer() -> Int? {
    switch self {
    case let .integer(integer): return integer
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func float() -> Double? {
    switch self {
    case let .float(float): return float
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func string() -> String? {
    switch self {
    case let .string(string): return string
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func absLength() -> AbsLength? {
    switch self {
    case let .absLength(absLength): return absLength
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func color() -> Color? {
    switch self {
    case let .color(color): return color
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func fontSize() -> FontSize? {
    switch self {
    case let .fontSize(fontSize): return fontSize
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func fontStretch() -> FontStretch? {
    switch self {
    case let .fontStretch(fontStretch): return fontStretch
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func fontStyle() -> FontStyle? {
    switch self {
    case let .fontStyle(fontStyle): return fontStyle
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func fontWeight() -> FontWeight? {
    switch self {
    case let .fontWeight(fontWeight): return fontWeight
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func mathStyle() -> MathStyle? {
    switch self {
    case let .mathStyle(mathStyle): return mathStyle
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func mathVariant() -> MathVariant? {
    switch self {
    case let .mathVariant(mathVariant): return mathVariant
    default: return nil
    }
  }

  @inlinable @inline(__always)
  public func textAlignment() -> NSTextAlignment? {
    switch self {
    case let .textAlignment(textAlignment): return textAlignment
    default: return nil
    }
  }
}
