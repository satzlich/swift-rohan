// Copyright 2024-2025 Lie Yan

import AppKit

enum ItemListSubtype: String, Codable, CaseIterable {
  case itemize
  case enumerate

  var command: String { rawValue }

  /// Instantiate text list for given level (1-based).
  func textList(forLevel level: Int) -> TextList {
    precondition(level >= 1)
    switch self {
    case .itemize:
      let marker: String =
        switch level % 3 {
        case 1: "\u{2022}"  // bullet
        case 2: "\u{2014}"  // em-dash
        case _: "\u{2217}"  // asterisk
        }
      return .itemize(marker: marker)

    case .enumerate:
      let formats: Array<NSTextList.MarkerFormat> =
        [.decimal, .lowercaseLatin, .lowercaseRoman]
      let format = formats[(level - 1) % 3]
      let textList = NSTextList(markerFormat: format, options: 0)
      return .enumerate(textList)
    }
  }

  enum TextList {
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
  }
}
