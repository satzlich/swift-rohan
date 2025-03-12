// Copyright 2024-2025 Lie Yan
import Foundation
import Testing

struct SerdeTestsUtils<T> where T: Codable {
  typealias DecodeFunc = (Data) throws -> T

  static func decodeFunc(for klass: T.Type) -> DecodeFunc {
    return { data in try JSONDecoder().decode(klass.self, from: data) }
  }

  static func testRoundTrip(
    _ object: T, _ expected: String, _ message: String? = nil
  ) throws {
    let decodeFunc = decodeFunc(for: T.self)
    try testRoundTrip(object, decodeFunc, expected, message)
  }

  static func testRoundTrip(
    _ object: T, _ decodeFunc: DecodeFunc, _ expected: String,
    _ message: String? = nil
  ) throws {
    let message = message ?? "\(T.self) round trip"

    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    // encode
    let encoded = try encoder.encode(object)
    #expect(String(data: encoded, encoding: .utf8) == expected, "\(message)")
    // decode
    let decoded = try decodeFunc(encoded)
    // encode again
    let reencoded = try encoder.encode(decoded)
    #expect(String(data: reencoded, encoding: .utf8) == expected, "\(message)")
  }
}
