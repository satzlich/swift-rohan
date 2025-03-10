// Copyright 2024-2025 Lie Yan

// Adapted from lexical-iOS

import Foundation

enum JSONValue: Codable, Equatable {
  case null
  case number(Float)
  case bool(Bool)
  case string(String)
  case object([String: JSONValue])
  case array([JSONValue])

  func encode(to encoder: Encoder) throws {
    // Unfortunately in Swift there is no way to "defer" serialization. Since this is intended to
    // be used with JSON primitives we support what JSON supports out of the box.
    var container = encoder.singleValueContainer()

    switch self {
    case .null:
      try container.encodeNil()
    case .bool(let value):
      try container.encode(value)
    case .number(let value):
      try container.encode(value)
    case .string(let value):
      try container.encode(value)
    case .object(let values):
      try container.encode(values)
    case .array(let values):
      try container.encode(values)
    }
  }

  init(from decoder: Decoder) throws {
    if let container = try? decoder.container(keyedBy: AnyCodingKey.self) {
      var values = [String: JSONValue]()

      for codingKey in container.allKeys {
        // According to the JSON spec, any valid key must be a double-quoted string. Therefore,
        // we assume keys are strings.
        values[codingKey.stringValue] = try JSONValue(
          from: container.superDecoder(forKey: codingKey))
      }

      self = .object(values)
    }
    else if var container = try? decoder.unkeyedContainer() {
      var values = [JSONValue]()

      if let count = container.count {
        values.reserveCapacity(count)
      }

      while !container.isAtEnd {
        values.append(try container.decode(JSONValue.self))
      }

      self = .array(values)
    }
    else if let container = try? decoder.singleValueContainer() {
      if let value = try? container.decode(Bool.self) {
        self = .bool(value)
      }
      else if let value = try? container.decode(Float.self) {
        self = .number(value)
      }
      else if let value = try? container.decode(Int.self) {
        self = .number(Float(value))
      }
      else if let value = try? container.decode(String.self) {
        self = .string(value)
      }
      else if container.decodeNil() {
        self = .null
      }
      else {
        throw SatzError(.InvalidJSON, message: "Unsupported value present in decoded node map")
      }
    }
    else {
      throw SatzError(.InvalidJSON, message: "Unsupported value present in decoded node map")
    }
  }

  struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
      self.stringValue = stringValue
    }

    init?(intValue: Int) {
      return nil
    }
  }
}
