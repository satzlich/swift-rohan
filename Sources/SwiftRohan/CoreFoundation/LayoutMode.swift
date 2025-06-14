// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

enum LayoutMode: CaseIterable {
  case textMode
  case mathMode

  var forLatexParser: LatexParser.LayoutMode {
    switch self {
    case .textMode: return .textMode
    case .mathMode: return .mathMode
    }
  }
}
