// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct TemplateSerdeTests {
  @Test
  func test_Template() throws {
    let template = Template(
      name: "test", parameters: ["x"],
      body: [TextExpr("Hello, "), VariableExpr("x", .inline)],
      layoutType: .inline)

    try assertSerde(
      template,
      """
      {"body":[{"string":"Hello, ","type":"text"},{"containerType":"inline","layoutType":0,"name":"x","type":"variable"}],"layoutType":0,"name":"test","parameters":["x"]}
      """)
  }

  @Test
  func test_CompiledTemplate() throws {
    let argument0: VariablePaths = [[.index(1)]]
    let template = CompiledTemplate(
      "test", [TextExpr("Hello, "), CompiledVariableExpr(0, .inline, .inline)],
      .inline, [argument0])
    try assertSerde(
      template,
      """
      {"body":[{"string":"Hello, ","type":"text"},{"argIndex":0,"containerType":"inline","layoutType":0,"levelDelta":0,"type":"cVariable"}],"layoutType":0,"lookup":[[[{"index":{"_0":1}}]]],"name":"test"}
      """)
  }

  func assertSerde<T: Codable>(_ value: T, _ expected: String) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let decoder = JSONDecoder()

    let data = try encoder.encode(value)
    #expect(String(data: data, encoding: .utf8) == expected)
    let decoded = try decoder.decode(T.self, from: data)
    let data2 = try encoder.encode(decoded)
    #expect(data == data2)
  }
}
