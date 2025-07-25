import Foundation

struct ContentTag: OptionSet, CaseIterable, Hashable {
  var rawValue: UInt32

  init(rawValue: UInt32) {
    self.rawValue = rawValue
  }

  static let plaintext = ContentTag(rawValue: 1 << 0)
  static let formula = ContentTag(rawValue: 1 << 1)
  static let styledText = ContentTag(rawValue: 1 << 2)

  static let allCases: Array<ContentTag> = [
    .plaintext,
    .formula,
    .styledText,
  ]
}
