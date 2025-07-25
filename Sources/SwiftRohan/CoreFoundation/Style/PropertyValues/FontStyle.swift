import AppKit
import Foundation

public enum FontStyle: Equatable, Hashable, Codable, Sendable, CaseIterable {
  case normal
  case italic

  public func symbolicTraits() -> NSFontDescriptor.SymbolicTraits {
    switch self {
    case .normal: return []
    case .italic: return .italic
    }
  }
}
