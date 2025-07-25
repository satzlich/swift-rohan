import Foundation

public struct TextToken: TokenProtocol {
  public let text: String
  public let mode: LayoutMode

  public init?(_ text: String, mode: LayoutMode) {
    guard TextToken.validate(text: text, mode: mode)
    else { return nil }
    self.text = text
    self.mode = mode
  }

  public init(rawValue: String, mode: LayoutMode) {
    self.text = rawValue
    self.mode = mode
  }
}

extension TextToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool {
    guard let first = text.first else { return false }
    return first.isLetter || first.isNumber
  }
}

extension TextToken {
  public func untokenize() -> String {
    text
  }
}
