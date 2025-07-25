import Foundation
import Testing

@testable import SwiftRohan

struct DelimiterTests {
  @Test
  func coverage() {
    let delimiters = [
      Delimiter.lvert,
      Delimiter.rvert,
      Delimiter.lVert,
      Delimiter.rVert,
      Delimiter(),
      Delimiter("(")!,
      Delimiter(")")!,
      Delimiter("[")!,
      Delimiter("]")!,
      Delimiter("{")!,
      Delimiter("}")!,
    ]

    for delimiter in delimiters {
      _ = delimiter.getComponentSyntax()
      _ = delimiter.matchingDelimiter()
      let json = delimiter.store()
      _ = Delimiter.load(from: json)
    }
  }

  @Test
  func failure() throws {
    _ = Delimiter("a")  // Should fail to create a delimiter
    _ = Delimiter(NamedSymbol.lookup("rightarrow")!)  // Should fail to create a delimiter

    do {
      let json = """
        [ ]
        """
      let data = Data(json.utf8)
      let decoder = JSONDecoder()
      let jsonValue = try decoder.decode(JSONValue.self, from: data)
      _ = Delimiter.load(from: jsonValue)
    }
  }
}
