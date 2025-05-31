// Copyright 2024-2025 Lie Yan

public typealias TextSyntax = TextToken

extension TextSyntax: SyntaxProtocol {
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    return [self]
  }

  public func deparse(
    _ preference: DeparsePreference, _ context: DeparseContext
  ) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      return deparse(context)
    case .properGroup, .wrapNonSymbol:
      return text.count == 1
        ? deparse(context)
        : wrapInGroup(deparse(context))
    }
  }
}

extension TextSyntax {
  /// Returns a sanitized version of the text segment.
  public static func sanitize(
    _ text: String, _ registry: LaTeXRegistry, mode: LayoutMode
  ) -> StreamSyntax {
    let subs = registry.getSubsTable(for: mode)

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
      else if let subTokens = subs[char]?.replacement {
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
      }

    case .textMode:
      return text.allSatisfy { char in
        !EscapedCharToken.isEscapeable(char)
      }

    case .rawMode:
      return true
    }
  }
}
