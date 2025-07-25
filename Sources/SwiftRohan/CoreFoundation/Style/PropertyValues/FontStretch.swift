import AppKit
import Foundation

public enum FontStretch: Equatable, Hashable, Codable, Sendable, CaseIterable {
  case condensed
  case normal
  case expanded

  public func symbolicTraits() -> NSFontDescriptor.SymbolicTraits {
    switch self {
    case .condensed:
      return .condensed
    case .normal:
      return []
    case .expanded:
      return .expanded
    }
  }
}
