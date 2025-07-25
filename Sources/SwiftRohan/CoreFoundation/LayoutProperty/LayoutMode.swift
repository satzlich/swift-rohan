import Foundation
import LatexParser

enum LayoutMode: CaseIterable {
  case textMode
  case mathMode

  var toLatexParserType: LatexParser.LayoutMode {
    switch self {
    case .textMode: return .textMode
    case .mathMode: return .mathMode
    }
  }
}
