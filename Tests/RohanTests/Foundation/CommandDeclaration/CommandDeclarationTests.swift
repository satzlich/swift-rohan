// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import Testing

@testable import SwiftRohan

struct CommandDeclarationTests {

  private func testCodable<T: CommandDeclarationProtocol>(_ obj: T) throws {
    let data = try JSONEncoder().encode(obj)
    _ = try JSONDecoder().decode(T.self, from: data)
  }

  @Test
  func encoding() throws {
    do {
      try testCodable(MathAttributes.limits)
      try testCodable(MathAttributes.mathbin)
    }
    do {
      try testCodable(MathStyles.mathStyle(.display))
      try testCodable(MathStyles.mathTextStyle(.mathbb))
      try testCodable(MathStyles.inlineStyle)
    }
    do {
      try testCodable(MathAccent.acute)
      try testCodable(MathArray.Bmatrix)
      try testCodable(MathExpression.bmod)
      try testCodable(MathGenFrac.atop)
      try testCodable(MathOperator.Pr)
      try testCodable(MathSpreader.overbrace)
      try testCodable(MathTemplate.operatorname)
      try testCodable(NamedSymbol.lookup("rightarrow")!)
    }
  }

  @Test
  func commandDeclaration() {
    _ = CommandDeclaration.lookup("rightarrow")
  }

  @Test
  func mathAccent() {
    _ = MathAccent.acute.subtype.isTop
    _ = MathAccent.acute.subtype.isBottom
  }

  @Test
  func mathArray() {
    let arrays: Array<MathArray> = [
      MathArray.Bmatrix,
      MathArray.aligned,
      MathArray.cases,
      MathArray.gathered,
      MathArray.substack,
    ]

    let font = Font.createWithName("STIX Two Math", 10)
    let mathContext = MathContext(font, .display, false, .black)!

    for array in arrays {
      _ = array.isMatrix
      _ = array.delimiters
      _ = array.getRowGap()
      _ = array.getColumnAlignments()
      _ = array.getColumnGapCalculator([], mathContext)
    }
  }
  
  @Test
  func mathKind() {
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
    let styles: [MathStyles] = [
      .mathStyle(.display),
      .mathTextStyle(.mathbb),
      .inlineStyle,
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
  func namedSymbol() {
    let symbol = NamedSymbol.lookup("rightarrow")!
    let symbol2 = NamedSymbol.lookup("S")!

    _ = symbol < symbol2
  }
}
