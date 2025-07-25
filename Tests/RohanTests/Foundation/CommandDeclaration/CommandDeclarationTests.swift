import CoreGraphics
import Foundation
import Testing

@testable import SwiftRohan

struct CommandDeclarationTests {

  private func standardCalls<T: CommandDeclarationProtocol>(_ command: T) throws {
    _ = command.command
    _ = command.source
    _ = command.tag
    _ = T.allCommands
    //
    do {
      let data = try JSONEncoder().encode(command)
      _ = try JSONDecoder().decode(T.self, from: data)
    }
  }

  @Test
  func encoding() throws {
    do {
      try standardCalls(MathAttributes.limits)
      try standardCalls(MathAttributes.mathbin)
      try standardCalls(MathAttributes.combo(.mathbin, .limits))
    }
    do {
      try standardCalls(MathStyles.mathStyle(.display))
      try standardCalls(MathStyles.mathTextStyle(.mathbb))
      try standardCalls(MathStyles.toInlineStyle)
    }
    do {
      try standardCalls(MathAccent.acute)
      try standardCalls(MathArray.Bmatrix)
      try standardCalls(MathExpression.bmod)
      try standardCalls(MathGenFrac.atop)
      try standardCalls(MathOperator.Pr)
      try standardCalls(MathSpreader.overbrace)
      try standardCalls(MathTemplate.operatorname)
      try standardCalls(NamedSymbol.lookup("rightarrow")!)
    }
  }

  @Test
  func commandDeclaration() throws {
    let command = CommandDeclaration.lookup("rightarrow")
    #expect(command != nil)
  }

  @Test
  func mathAccent() throws {
    _ = MathAccent.acute.subtype.isTop
    _ = MathAccent.acute.subtype.isBottom
  }

  @Test
  func mathArray() throws {
    let arrays: Array<MathArray> = [
      MathArray.Bmatrix,
      MathArray.aligned,
      MathArray.cases,
      MathArray.gathered,
      MathArray.substack,
      MathArray.multlineAst,
    ]

    let font = Font.createWithName("STIX Two Math", 10)
    let mathContext = MathContext(font, .display, false, .black)!

    let rowCount = 3
    let columns = (0..<3).map { _ in [MathListLayoutFragment(mathContext)] }

    for array in arrays {
      _ = array.isMatrix
      _ = array.delimiters
      _ = array.getRowGap()

      //
      let cellAlignments = array.getCellAlignments(rowCount)
      _ = cellAlignments.get(0)
      for i in 0..<rowCount {
        _ = cellAlignments.get(i, 0)
      }

      //
      let columnGaps = array.getColumnGapCalculator(columns, mathContext)
      _ = columnGaps.get(0)
    }
  }

  @Test
  func mathAttributes() throws {
    let attributes = MathAttributes.combo(.mathbin, .limits)

    _ = attributes.mathClass
    _ = attributes.limits
  }

  @Test
  func mathKind() throws {
    for kind in MathKind.allCases {
      _ = kind.mathClass
    }

    _ = MathKind.lookup("mathbin")
  }

  @Test
  func mathLimits() {
    _ = MathLimits.lookup("limits")
  }

  @Test
  func mathStyles() {
    let styles: Array<MathStyles> = [
      .mathStyle(.display),
      .mathTextStyle(.mathbb),
      .toInlineStyle,
    ]

    for style in styles {
      _ = style.command
      _ = style.source
      _ = style.tag
      _ = style.preview()
    }
  }

  @Test
  func mathTextStyles() {
    let styles = MathTextStyle.allCases
    for style in styles {
      _ = style.command
      _ = style.source
      _ = style.tag
      _ = style.preview()
      _ = style.tuple()

      _ = MathTextStyle.lookup(style.command)
    }
  }
  
  @Test
  func mathTemplate_decodeThrows() throws {
    let json =
    """
    {"subtype": "commandCall", "command": "nonexistent"}
    """
    let decoder = JSONDecoder()
    
    #expect(throws: DecodingError.self) {
      try decoder.decode(MathTemplate.self, from: Data(json.utf8))
    }
  }

  @Test
  func namedSymbol() {
    let symbol = NamedSymbol.lookup("rightarrow")!
    let symbol2 = NamedSymbol.lookup("S")!

    _ = symbol < symbol2
  }
}
