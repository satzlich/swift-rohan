// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct TemplateSerdeTests {
  @Test
  static func test_Template() throws {
    let template = Template(
      name: "test", parameters: ["x"],
      body: [TextExpr("Hello, "), VariableExpr("x")])

    try SerdeTestsUtils.testRoundTrip(
      template,
      """
      {"body":[{"string":"Hello, ","type":"text"},{"name":"x","type":"variable"}],"name":"test","parameters":["x"]}
      """
    )
  }

  @Test
  static func test_CompiledTemplate() throws {
    let argument0: VariablePaths = [
      [.index(1)]
    ]
    let template = CompiledTemplate(
      "test", [TextExpr("Hello, "), CompiledVariableExpr(0)], [argument0])
    try SerdeTestsUtils.testRoundTrip(
      template,
      """
      {"body":[{"string":"Hello, ","type":"text"},{"index":0,"type":"cVariable"}],\
      "lookup":[[[{"index":{"_0":1}}]]],\
      "name":"test"}
      """)
  }
}
