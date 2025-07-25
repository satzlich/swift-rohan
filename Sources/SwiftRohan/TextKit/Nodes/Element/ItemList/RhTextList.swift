import AppKit

/// Parallel to `NSTextList`.
enum RhTextList {
  case itemize(level: Int, marker: String)
  case enumerate(level: Int, textList: NSTextList)

  var level: Int {
    switch self {
    case .itemize(let level, _): return level
    case .enumerate(let level, _): return level
    }
  }

  private func _marker(forItemNumber itemNumber: Int) -> String {
    switch self {
    case let .itemize(_, marker):
      return marker

    case let .enumerate(_, textList):
      let marker = textList.marker(forItemNumber: itemNumber)
      let formatted: String =
        switch textList.markerFormat {
        case .lowercaseLatin, .lowercaseLatin, .uppercaseAlpha, .uppercaseLatin:
          "(\(marker))"
        case _:
          "\(marker)."
        }
      return formatted
    }
  }

  func marker(forIndex index: Int) -> String {
    _marker(forItemNumber: index + 1)
  }
}
