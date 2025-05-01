// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public enum FontWeight: Equatable, Hashable, Codable, Sendable {
  case regular
  case bold

  public func symbolicTraits() -> NSFontDescriptor.SymbolicTraits {
    switch self {
    case .regular: return []
    case .bold: return .bold
    }
  }
}
