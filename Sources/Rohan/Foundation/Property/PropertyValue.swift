// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public enum PropertyValue: Equatable, Hashable, Codable, Sendable {
  case none

  // basic types
  case bool(Bool)
  case integer(Int)
  case float(Double)
  case string(String)

  // general
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
  public func bool() -> Bool? {
    switch self {
    case let .bool(bool): return bool
    default: return nil
    }
  }

  public func integer() -> Int? {
    switch self {
    case let .integer(integer): return integer
    default: return nil
    }
  }

  public func float() -> Double? {
    switch self {
    case let .float(float): return float
    default: return nil
    }
  }

  public func string() -> String? {
    switch self {
    case let .string(string): return string
    default: return nil
    }
  }

  public func color() -> Color? {
    switch self {
    case let .color(color): return color
    default: return nil
    }
  }

  public func fontSize() -> FontSize? {
    switch self {
    case let .fontSize(fontSize): return fontSize
    default: return nil
    }
  }

  public func fontStretch() -> FontStretch? {
    switch self {
    case let .fontStretch(fontStretch): return fontStretch
    default: return nil
    }
  }

  public func fontStyle() -> FontStyle? {
    switch self {
    case let .fontStyle(fontStyle): return fontStyle
    default: return nil
    }
  }

  public func fontWeight() -> FontWeight? {
    switch self {
    case let .fontWeight(fontWeight): return fontWeight
    default: return nil
    }
  }

  public func mathStyle() -> MathStyle? {
    switch self {
    case let .mathStyle(mathStyle): return mathStyle
    default: return nil
    }
  }

  public func mathVariant() -> MathVariant? {
    switch self {
    case let .mathVariant(mathVariant): return mathVariant
    default: return nil
    }
  }

  public func textAlignment() -> NSTextAlignment? {
    switch self {
    case let .textAlignment(textAlignment): return textAlignment
    default: return nil
    }
  }
}
