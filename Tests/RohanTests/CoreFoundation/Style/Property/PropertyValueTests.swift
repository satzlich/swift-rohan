// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct PropertyValueTests {
  @Test
  func memoryLayoutSize() {
    #expect(MemoryLayout<String>.size == 16)
    #expect(MemoryLayout<Color>.size == 8)
    #expect(MemoryLayout<PropertyValue>.size == 17)
  }

  @Test
  func coverage() {
    // basic

    do {
      let value: PropertyValue = .none
      #expect(value.bool() == nil)
      #expect(value.type == .none)
    }

    do {
      let value: PropertyValue = .bool(true)
      #expect(value.bool() == true)
      #expect(value.integer() == nil)
      #expect(value.type == .bool)
    }

    do {
      let value: PropertyValue = .integer(42)
      #expect(value.integer() == 42)
      #expect(value.float() == nil)
      #expect(value.type == .integer)
    }

    do {
      let value: PropertyValue = .float(3.14)
      #expect(value.float() == 3.14)
      #expect(value.string() == nil)
      #expect(value.type == .float)
    }

    do {
      let value: PropertyValue = .string("Hello")
      #expect(value.string() == "Hello")
      #expect(value.absLength() == nil)
      #expect(value.type == .string)
    }

    // general

    do {
      let value: PropertyValue = .absLength(.cm(13))
      #expect(value.absLength() == .cm(13))
      #expect(value.color() == nil)
      #expect(value.type == .absLength)
    }

    do {
      let value: PropertyValue = .color(.red)
      #expect(value.color() == .red)
      #expect(value.fontSize() == nil)
      #expect(value.type == .color)
    }

    // font

    do {
      let value: PropertyValue = .fontSize(12.0)
      #expect(value.fontSize() == 12.0)
      #expect(value.fontStretch() == nil)
      #expect(value.type == .fontSize)
    }

    do {
      let value: PropertyValue = .fontStretch(.condensed)
      #expect(value.fontStretch() == .condensed)
      #expect(value.fontStyle() == nil)
      #expect(value.type == .fontStretch)
    }

    do {
      let value: PropertyValue = .fontStyle(.italic)
      #expect(value.fontStyle() == .italic)
      #expect(value.fontWeight() == nil)
      #expect(value.type == .fontStyle)
    }

    do {
      let value: PropertyValue = .fontWeight(.bold)
      #expect(value.fontWeight() == .bold)
      #expect(value.mathStyle() == nil)
      #expect(value.type == .fontWeight)
    }

    // math

    do {
      let value: PropertyValue = .mathStyle(.text)
      #expect(value.mathStyle() == .text)
      #expect(value.mathVariant() == nil)
      #expect(value.type == .mathStyle)
    }

    do {
      let value: PropertyValue = .mathVariant(.frak)
      #expect(value.mathVariant() == .frak)
      #expect(value.textAlignment() == nil)
      #expect(value.type == .mathVariant)
    }

    // paragraph
    do {
      let value: PropertyValue = .textAlignment(.left)
      #expect(value.textAlignment() == .left)
      #expect(value.bool() == nil)
      #expect(value.type == .textAlignment)
    }
  }
}
