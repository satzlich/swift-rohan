// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

/** Defines situations where limits should be applied. */
enum Limits: Equatable, Hashable, Codable {
  /** Never apply limits; instead, attach scripts. */
  case never
  /** Apply limits only in `display` style. */
  case display
  /** Always apply limits. */
  case always

  /** Whether limits should be displayed in this context */
  public func isActive(in mathStyle: MathStyle) -> Bool {
    switch self {
    case .never: false
    case .display: mathStyle == .display
    case .always: true
    }
  }

  /** The default limit configuration if the given character is the base. */
  public static func defaultValue(forChar char: UnicodeScalar) -> Limits {
    switch char.mathClass {
    case .Large: MathUtils.isIntegralChar(char) ? .never : .display
    case .Relation: .always
    default: .never
    }
  }

  /** The default limit configuration for a math class. */
  public static func defaultValue(forMathClass clazz: MathClass) -> Limits {
    switch clazz {
    case .Large: .display
    case .Relation: .always
    default: .never
    }
  }
}
