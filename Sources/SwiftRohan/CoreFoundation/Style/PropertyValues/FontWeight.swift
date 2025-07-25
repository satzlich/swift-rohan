import AppKit
import Foundation

public enum FontWeight: Equatable, Hashable, Codable, Sendable, CaseIterable {
  case regular
  case bold

  public func symbolicTraits() -> NSFontDescriptor.SymbolicTraits {
    switch self {
    case .regular: return []
    case .bold: return .bold
    }
  }
}
