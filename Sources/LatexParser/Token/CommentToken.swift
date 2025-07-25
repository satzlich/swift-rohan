public struct CommentToken: TokenProtocol {
  public var commentChar: Character { "%" }
  public let content: String

  public init(_ content: String) {
    self.content = content
  }

}

extension CommentToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension CommentToken {
  public func untokenize() -> String {
    "\(commentChar)\(content)"
  }
}
