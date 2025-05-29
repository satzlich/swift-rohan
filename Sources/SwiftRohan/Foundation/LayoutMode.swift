// Copyright 2024-2025 Lie Yan

import Foundation
import LaTeXParser

enum LayoutMode {
  case textMode
  case mathMode

  var forLaTeXParser: LaTeXParser.LayoutMode {
    switch self {
    case .textMode: return .textMode
    case .mathMode: return .mathMode
    }
  }
}
