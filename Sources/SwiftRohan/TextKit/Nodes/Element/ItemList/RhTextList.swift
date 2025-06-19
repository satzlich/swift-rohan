// Copyright 2024-2025 Lie Yan

import AppKit

/// Parallel to `NSTextList`.
enum RhTextList {
  case itemize(marker: String)
  case enumerate(NSTextList)

  func marker(forItemNumber itemNumber: Int) -> String {
    switch self {
    case let .itemize(marker):
      return marker

    case let .enumerate(textList):
      let marker = textList.marker(forItemNumber: itemNumber)
      let formatted: String =
        switch textList.markerFormat {
        case .lowercaseLatin, .uppercaseLatin: "(\(marker))"
        case _: "\(marker)."
        }
      return formatted
    }
  }

  func marker(forIndex index: Int) -> String {
    marker(forItemNumber: index + 1)
  }
}
