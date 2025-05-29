// Copyright 2024-2025 Lie Yan

public typealias TextSyntax = TextToken

extension TextSyntax: SyntaxProtocol {
  public func deparse() -> Array<any TokenProtocol> {
    return [self]
  }

  public func deparse(_ preference: DeparsePreference) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      return deparse()
    case .properGroup:
      return text.count == 1
        ? deparse()
        : wrapInGroup(deparse())
    }
  }
}

extension TextSyntax {
  /// Returns a sanitized version of the text segment.
  public static func sanitize(_ text: String, mode: LayoutMode) -> StreamSyntax {
    let subs = mode == .mathMode ? TextSyntax.MSUB : [:]

    var stream: [StreamletSyntax] = []
    var segment: String = ""

    //
    func appendSegmentIfNeeded() {
      if !segment.isEmpty {
        stream.append(StreamletSyntax(TextSyntax(segment, mode: mode)!))
        segment = ""
      }
    }

    for char in text {
      if EscapedCharToken.isEscapeable(char) {
        appendSegmentIfNeeded()
        stream.append(StreamletSyntax(EscapedCharSyntax(char: char)!))
      }
      else if let subTokens = subs[char] {
        appendSegmentIfNeeded()
        stream.append(contentsOf: subTokens)
      }
      else {
        segment.append(char)
      }
    }
    appendSegmentIfNeeded()
    return StreamSyntax(stream)
  }

  public static func validate(text: String, mode: LayoutMode) -> Bool {
    switch mode {
    case .mathMode:
      return text.allSatisfy { char in
        !EscapedCharToken.isEscapeable(char)
          && TextSyntax.MSUB[char] == nil
      }

    case .textMode:
      return text.allSatisfy { char in
        !EscapedCharToken.isEscapeable(char)
      }

    case .undefined:
      return true
    }
  }

  private typealias SubTable = Dictionary<Character, Array<StreamletSyntax>>

  /// substitution table for math mode
  private static let MSUB: SubTable = [
    "\u{2032}": [.controlSeq(ControlSeqSyntax(command: ControlSeqToken.prime))],
    "\u{2033}": [.controlSeq(ControlSeqSyntax(command: ControlSeqToken.dprime))],
    "\u{2034}": [.controlSeq(ControlSeqSyntax(command: ControlSeqToken.trprime))],
    "\u{2057}": [.controlSeq(ControlSeqSyntax(command: ControlSeqToken.qprime))],
  ]
}
